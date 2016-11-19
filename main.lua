local System = require 'lib.knife.system'

local updateMotion = System(
    { 'position', 'velocity' },
    function (p, v, dt, player)
        print('je bouge:')
    end
)
  
require "character"

-- lv1 enemies
local entities = require "levels.1.badguys"

local sti = require "lib.sti"
-- local anim8 = require "lib.anim8"
local inspect = require "lib.inspect"

local image, spriteLayer, player

-- Enabling debug mode
local debug = false

function love.load()
  
    batImg = love.graphics.newImage("assets/images/sprites2.png")
    
    -- Set world meter size (in pixels)
    love.physics.setMeter(48)

    -- Load a map exported to Lua from Tiled
    map = sti("assets/tilesets/map_lulu.lua", { "box2d" })

    -- Prepare physics world with horizontal and vertical gravity
    world = love.physics.newWorld(0, 0)

    -- Prepare collision objects
    map:box2d_init(world)
    world:setCallbacks(beginContact)

    -- Create a Custom Layer
    map:addCustomLayer("Sprite Layer", 4)

    -- Add data to Custom Layer
    image = love.graphics.newImage("assets/images/sprite.png")
    spriteLayer = map.layers["Sprite Layer"]
    
    -- appending player
    myPlayer = Character(0, 0, "assets/images/sprite.png")
    spriteLayer.sprites = {player = myPlayer:draw()}

    -- Get player spawn object from Tiled
    local playerObj
    for k, object in pairs(map.objects) do
        if object.name == "player" then
            playerObj = object
            break
        end
    end

    player = spriteLayer.sprites.player
    player.body = love.physics.newBody(world, playerObj.x, playerObj.y, 'dynamic')
    player.body:setLinearDamping(10)
    player.body:setFixedRotation(true)
    player.shape = love.physics.newRectangleShape(14, 14)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    
    -- Update callback for Custom Layer
--    function spriteLayer:update(dt)

--    end

    -- Draw callback for Custom Layer
    function spriteLayer:draw()
        for _, sprite in pairs(self.sprites) do
            local x = math.floor(sprite.x)
            local y = math.floor(sprite.y)
            local r = sprite.r
            love.graphics.draw(sprite.image, x, y)
        end
    end
end

function love.update(dt)
  
--    for _, entity in ipairs(entities) do
--        updateMotion(entity, dt, player)
--    end
    
    local down = love.keyboard.isDown
  
    local x, y= 0, 0
    local speed = 100
    
    if down("z","up") and player.y > 8    then y = y - speed end
    if down("s","down")     then y = y + speed end
    if down("q", "left") and player.x > 8    then x = x - speed end
    if down("d", "right") then  x = x + speed end
    player.body:applyForce(x, y)
    player.x = player.body:getX() - 4
    player.y = player.body:getY() - 4

    -- updates routines
    map:update(dt)
    world:update(dt)
end

function love.draw()
  
    -- draw entities
    for _, entity in ipairs(entities) do
        local char = Character(entity.pos.x, entity.pos.y, entity.sprite)
        table.insert(spriteLayer.sprites, char:draw())
    end
    
      -- Scale world
    local scale = 2
    local screen_width = love.graphics.getWidth() / scale
    local screen_height = love.graphics.getHeight() / scale

    -- Translate world so that player is always centred
    local tx = math.floor(player.x - screen_width / 2)
    local ty = math.floor(player.y - screen_height / 2)

    -- Transform world
    love.graphics.scale(scale)
    love.graphics.translate(-tx, -ty)

    -- Draw the map and all objects within
    map:draw()

    if debug then
      -- Draw Collision Map
      love.graphics.setColor(255, 0, 0, 255)
      map:box2d_draw()
      love.graphics.polygon("line", player.body:getWorldPoints(player.shape:getPoints()))
      
      -- player debug
      love.graphics.setColor(255, 255, 0, 255)
      love.graphics.setPointSize(5)
      love.graphics.points(math.floor(player.x), math.floor(player.y))
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print(math.floor(player.x)..','..math.floor(player.y), player.x-16, player.y-16)
    end
end