-- This example uses the default box2d (love.physics) plugin!!
require "Projectile"

local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local inspect = require "lib.inspect"

local image, animation

-- gestion des shoots
local bullets={}
-- Enabling debug mode
local debug = true

function love.load()
    -- Set world meter size (in pixels)
    love.physics.setMeter(48)

    -- Load a map exported to Lua from Tiled
    map = sti("assets/tilesets/map.lua", { "box2d" })

    -- Prepare physics world with horizontal and vertical gravity
    world = love.physics.newWorld(0, 0)

    -- construct character animations
    image = love.graphics.newImage("assets/images/sprites2.png")
    local idle = anim8.newGrid(16, 16, image:getWidth(), image:getHeight())
    animation = anim8.newAnimation(idle('1-3',1), 0.5)

    -- Prepare collision objects
    map:box2d_init(world)
    world:setCallbacks(beginContact)

    -- Create a Custom Layer
    map:addCustomLayer("Sprite Layer", 4)

    -- Add data to Custom Layer
    --image = love.graphics.newImage("assets/images/sprite.png")
    spriteLayer = map.layers["Sprite Layer"]
    spriteLayer.sprites = {
        player = {
            image = love.graphics.newImage("assets/images/sprites2.png"),
            x = 0,
            y = 0
        }
    }

    -- Get player spawn object from Tiled
    local playerObj
    for k, object in pairs(map.objects) do
        if object.name == "Player" then
            playerObj = object
            break
        end
    end
    print(inspect(playerObj))

    player = spriteLayer.sprites.player
    player.body = love.physics.newBody(world, playerObj.x, playerObj.y, 'dynamic')
    player.body:setLinearDamping(10)
    player.body:setFixedRotation(true)

    player.shape = love.physics.newRectangleShape(14, 14)
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
            animation:draw(sprite.image, x - 3, y - 3)
        end
    end
end

function love.update(dt)

    local down = love.keyboard.isDown
    local up = love.keyreleased(key)
    
    local x, y= 0, 0
    local speed = 48
    
    if down("z","up") and player.y > 8    then y = y - speed end
    if down("s","down")     then y = y + speed end
    if down("q", "left") and player.x > 8    then x = x - speed end
    if down("d", "right")    then x = x + speed end
    
    player.body:applyForce(x, y)
    player.x = player.body:getX() - 4
    player.y = player.body:getY() - 4

    -- update bullets:
  local i,o
	for i, o in ipairs(bullets) do
		o.x = o.x + o.speed * dt
		--o.y = o.y + o.speed * dt
		if (bullets[i].x < -10) or (bullets[i].x > love.graphics.getWidth() + 10)
		or (o.y < -10) or (o.y > love.graphics.getHeight() + 10) then
			table.remove(bullets, i)
    end
	end

    -- updates routines
    animation:update(dt)
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

    -- draw bullets:
	love.graphics.setColor(255, 255, 255, 224)
	
  local i, o
	for i, o in pairs(bullets) do  
      love.graphics.circle('fill', o.x, o.y, 5, 4)
  end

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

function love.keyreleased(key, unicode)
   if key == 'space' then
    local direction = math.atan2(player.y+20, player.x+10)
        prjt = Projectile(player.x+10,player.y,100,direction,"assets/images/paper.png")
        table.insert(bullets,prjt:draw())
   end
end