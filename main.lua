local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local inspect = require "lib.inspect"

require "character"
require "Projectile"

-- lv1 enemies
local entities = require "levels.1.badguys"
local System = require 'lib.knife.system'

local image, spriteLayer, player, sound
-- Enabling debug mode
local debug = false

local updateMotion = System(
    { 'name', 'pos', 'vel' },
    function (name, pos, vel, dt)
        local badGuy = spriteLayer.sprites[name]
        local x, y = 0, 0
        local speed = 36
        
        -- targets the player, with velocity factor
        if badGuy.x > player.x then x = x - speed * vel.x else  x = x + speed * vel.x end
        if badGuy.y > player.y then y = y - speed * vel.y else y = y + speed * vel.y end

        badGuy.body:applyForce(x, y)
        badGuy.x = badGuy.body:getX() - 8
        badGuy.y = badGuy.body:getY() - 8
    end)

-- gestion des shoots
local bullets = {}
local nb_pages = 100

function love.load()
    -- Set world meter size (in pixels)
    love.physics.setMeter(48)

    -- Load a map exported to Lua from Tiled
    map = sti("assets/tilesets/map_lulu.lua", { "box2d" })

    -- Prepare physics world with horizontal and vertical gravity
    world = love.physics.newWorld(0, 0, true)
        world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    
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
    spriteLayer.sprites = { player = myPlayer:draw() }

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
    player.lives = 20
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setUserData('Player')

    -- draw entities
    for _, entity in ipairs(entities) do
        local char = Character(entity.pos.x, entity.pos.y, entity.sprite, entity.sound)
        spriteLayer.sprites[entity.name] = char:draw()
        local charObj = spriteLayer.sprites[entity.name]
        charObj.body = love.physics.newBody(world, entity.pos.x, entity.pos.y, 'dynamic')
        charObj.body:setLinearDamping(10)
        charObj.body:setFixedRotation(true)
        charObj.shape = love.physics.newRectangleShape(14, 14)
        charObj.fixture = love.physics.newFixture(charObj.body, charObj.shape)
        charObj.fixture:setUserData(entity.name)
        charObj.fixture:setRestitution(5)
    end
    
    -- Draw callback for Custom Layer
    function spriteLayer:draw()
        for _, sprite in pairs(self.sprites) do
            local x = math.floor(sprite.x)
            local y = math.floor(sprite.y)
            local r = sprite.r
            love.graphics.draw(sprite.image, x, y)
        end
    end
    
    -- welcome sound
    local welcomeSound = love.audio.newSource("assets/sounds/Lets_go.wav", "static")
    welcomeSound:play()
end

function love.update(dt)
    
    -- update entities
    for _, entity in ipairs(entities) do
      updateMotion(entity, dt)
      local obj = spriteLayer.sprites[entity.name]
    end
    -- love.event.quit()
    
    --nombre de tirs restants
    love.graphics.print("Dossier pole emplois :" .. nb_pages, 0, 0)
    local down = love.keyboard.isDown
    local up = love.keyreleased(key)

    local x, y = 0, 0
    local speed = 48

    if down("z", "up") and player.y > 8 then y = y - speed end
    if down("s", "down") then y = y + speed end
    if down("q", "left") and player.x > 8 then x = x - speed end
    if down("d", "right") then x = x + speed end

    player.body:applyForce(x, y)
    player.x = player.body:getX() - 8
    player.y = player.body:getY() - 8

    -- update bullets:
    local i, o
    for i, o in ipairs(bullets) do
        o.x = o.x + o.speed * dt
        --o.y = o.y + o.speed * dt
        if (o.x < -10) or (o.x > love.graphics.getWidth() + 10)
                or (o.y < -10) or (o.y > love.graphics.getHeight() + 10) then
            table.remove(bullets, i)
        end
    end

    -- updates routines
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
        love.graphics.setColor(255, 0, 0, 50)
        map:box2d_draw()

        -- player debug
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.polygon("line", player.body:getWorldPoints(player.shape:getPoints()))
        love.graphics.print(math.floor(player.x) .. ',' .. math.floor(player.y), player.x - 16, player.y - 16)    
        
        -- entities debug
        love.graphics.setColor(255, 0, 0, 255)
        for _, entity in ipairs(entities) do
          local badGuy = spriteLayer.sprites[entity.name]
          love.graphics.polygon("line", badGuy.body:getWorldPoints(player.shape:getPoints()))
          love.graphics.print(math.floor(badGuy.x) .. ',' .. math.floor(badGuy.y), badGuy.x - 16, badGuy.y - 16)
        end
        love.graphics.setColor(255, 255, 255, 255)
    end
    
    -- "HUD"
    
    love.graphics.setColor(0, 100, 100, 200)
    love.graphics.rectangle('fill', player.x - 300, player.y + 130, 1000,1000)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print('Lives '..player.lives, player.x + 120,  player.y + 135)   
    
    love.graphics.setColor(255, 255, 255, 255)
end

function love.keyreleased(key, unicode)
    if key == 'space' then
        local direction = math.atan2(player.y + 20, player.x + 10)
        prjt = Projectile(player.x + 10, player.y, 100, direction, "assets/images/paper.png")
        table.insert(bullets, prjt:draw())
        nb_pages = nb_pages - 1
    end
end

function beginContact(a, b, coll)
    x,y = coll:getNormal()
    -- if something collide with the players
    if a:getUserData() == 'Player' then
      -- play ennemy sound
      local ennemy = spriteLayer.sprites[b:getUserData()]
      local ennemySound = love.audio.newSource(ennemy.sound)
      ennemySound:play()
      player.lives = player.lives - 1
      if player.lives == 0 then
          love.event.quit('restart')
      end
    end
end
