-- This example uses the default box2d (love.physics) plugin!!

local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local inspect = require "lib.inspect"

function love.load()
    -- Grab window size
    windowWidth  = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()

    -- Set world meter size (in pixels)
    love.physics.setMeter(70)

    -- Load a map exported to Lua from Tiled
    map = sti("assets/tilesets/map.lua", { "box2d" })

    -- Prepare physics world with horizontal and vertical gravity
    world = love.physics.newWorld(0, 0)

    -- Prepare collision objects
    map:box2d_init(world)
    world:setCallbacks(beginContact)

    -- Create a Custom Layer
    map:addCustomLayer("Sprite Layer", 2)

    -- Add data to Custom Layer
    image = love.graphics.newImage("assets/images/sprite.png")
    local spriteLayer = map.layers["Sprite Layer"]
    spriteLayer.sprites = {
        player = {
            image = love.graphics.newImage("assets/images/sprite.png"),
            x = 0,
            y = 0,
            xvel = 0,
            yvel = 0
        }
    }

    player = spriteLayer.sprites.player
    player.body = love.physics.newBody(world, player.x + player.image:getWidth()/2, player.y + player.image:getHeight()/2, 'dynamic')
    player.body:setLinearDamping(10)
    player.body:setFixedRotation(true)

    player.shape = love.physics.newRectangleShape(16, 16)
    player.fixture = love.physics.newFixture(player.body, player.shape)

    -- Update callback for Custom Layer
    function spriteLayer:update(dt)

    end

    -- Draw callback for Custom Layer
    function spriteLayer:draw()
        for _, sprite in pairs(self.sprites) do
            local x = math.floor(sprite.x)
            local y = math.floor(sprite.y)
            local r = sprite.r
            love.graphics.draw(sprite.image, x, y, r)
        end
    end
end

function love.update(dt)
    world:update(dt)
    local down = love.keyboard.isDown
  
    local x, y= 0, 0
    local speed = 48

    if down("z","up")     then y = y - speed end
    if down("s","down")     then y = y + speed end
    if down("q", "left")     then x = x - speed end
    if down("d", "right")    then x = x + speed end
    player.body:applyForce(x, y)
    player.x = player.body:getX() - player.image:getWidth() / 2
    player.y = player.body:getY() - player.image:getHeight()/2

    player.x = player.x + (speed * dt)
    map:update(dt)
    world:update(dt)
end

function love.draw()
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

    -- Translation would normally be based on a player's x/y
    local translateX = 0
    local translateY = 0

    -- Draw the map and all objects within
    map:draw()

    -- Draw Collision Map (useful for debugging)
    love.graphics.setColor(255, 0, 0, 255)
    map:box2d_draw()

    -- Draw character lines
    love.graphics.polygon("line", player.body:getWorldPoints(player.shape:getPoints()))
--    love.graphics.pop()

    -- Reset color
    love.graphics.setColor(255, 255, 255, 255)
end