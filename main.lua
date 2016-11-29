local sti = require "lib.sti"
local anim8 = require "lib.anim8"
local inspect = require "lib.inspect"

require "character"
require "Projectile"
require "functions"

-- lv1 enemies
local entities = {} --= require "levels.1.badguys"
local levels = require "levels.levels"
local System = require 'lib.knife.system'

local image, spriteLayer, player, exit, sound

-- Enabling debug mode
local debug = false

local reload = false

function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

-------------------------------------------------------------------
-- This function checks collision between a bullet and an entity --
-------------------------------------------------------------------
local checkIfCollide = System({ 'name' },
    function(name, bullet, bullets_tab, i)
        if spriteLayer.sprites[name] then
            local badGuy = spriteLayer.sprites[name]
            if not badGuy.body:isDestroyed() then
                local badX, badY = badGuy.body:getPosition()
                if
                bullet.x >= badX - 8 and bullet.x <= badX + 8
                        and bullet.y >= badY - 8 and bullet.y <= badY + 8
                then
                    local ennemySound = love.audio.newSource(badGuy.deathSound, 'static')
                    ennemySound:play()
                    -- remove layer then destroy body
                    table.removekey(spriteLayer.sprites, name)
                    badGuy.body:destroy()
                    table.removekey(bullets_tab, i)
                end
            end
        end
    end)
------------------------------------------------------------------

------------------------------------------------------------------
-- This function moves entities to targets the player position  --
------------------------------------------------------------------
local updateMotion = System({ 'name', 'vel' },
    function(name, vel)
        if spriteLayer.sprites[name] then
            local badGuy = spriteLayer.sprites[name]
            if not badGuy.body:isDestroyed() then
                local x, y = 0, 0
                local speed = 36

                -- targets the player, with velocity factor
                if badGuy.x > player.x then x = x - speed * vel.x else x = x + speed * vel.x end
                if badGuy.y > player.y then y = y - speed * vel.y else y = y + speed * vel.y end

                badGuy.body:applyForce(x, y)
                badGuy.x = badGuy.body:getX() - 8
                badGuy.y = badGuy.body:getY() - 8
            end
        end
    end)
---------------------------------------------------------------------

-- gestion des shoots
local bullets = {}
local nbPages = 10

local direction_player = 1;
-- game state
local state = 'intro'
local currentLevel = 1

-- player date
local playerLives = 10


function love.load()
    love.window.setTitle('Chômeur Simulator 2K17')
    introLoad()
end

function love.update(dt)
    if state == 'intro' then
        introUpdate(dt)
    elseif state == 'howto' then
        howToUpdate(dt)
    elseif state == 'gameover' then
        gameOverUpdate(dt)
    elseif state == 'gamewin' then
        gameWinUpdate(dt)
    else
        levelUpdate(dt)
    end
end


function love.draw()
    if state == 'intro' then
        introDraw()
    elseif state == 'howto' then
        howToDraw(dt)
    elseif state == 'gameover' then
        gameOverDraw()
    elseif state == 'gamewin' then
        gameWinDraw()
    elseif state == 'morepage' then
        gameMorePageDraw()
    else
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
            printDebug(spriteLayer, entities, player, exit)
        end

        -- "HUD"
        printHud(player, nbPages)
    end
end

function love.keyreleased(key, unicode)
    if (key == 'space' or key == 'j') and player then
        if nbPages > 0 then
            prjt = Projectile(player.x + 10, player.y, 100, direction_player, "assets/images/paper.png")
            table.insert(bullets, prjt:draw())
            nbPages = nbPages - 1
        end
    end
    if key == 'r' then
        reload = false
    end
end

--------------

-- ***********************
-- INTRO FUNCTIONS
-- ***********************

local splashScreen, splashTitle, splashCommand, howTo, death, winner, pushJ
local splashTransX = 0
local splashTransY = 0
local splashTransSpeed = 0.1
local splashMusic = love.audio.newSource("assets/sounds/crazy_frog_techno.wav")

-- Intro screen load
function introLoad()
    splashScreen = love.graphics.newImage("assets/images/splashScreen.png")
    splashTitle = love.graphics.newImage("assets/images/splashTitle.png")
    splashCommand = love.graphics.newImage("assets/images/splashCommand.png")
    howTo = love.graphics.newImage("assets/images/howto.png")
    death = love.graphics.newImage("assets/images/death.png")
    winner = love.graphics.newImage("assets/images/winner.png")
    pushJ = love.graphics.newImage("assets/images/pushJ.png")
    splashMusic:play()
    splashMusic:setVolume(0.7)
end

function introUpdate(dt)
    local down = love.keyboard.isDown
    love.graphics.translate(dt, dt)

    -- splash music loop
    if splashMusic:isStopped() then
        splashMusic:play()
    end

    if down("space") then
        love.audio.stop(splashMusic)
        state = "howto"
    end
end

function introDraw()
    love.graphics.draw(splashScreen, splashTransX, splashTransY, 0, 0.8, 0.8, 0)
    love.graphics.draw(splashTitle, 0, 300)
    love.graphics.draw(splashCommand, 400, 550, 0, 0.5, 0.5)
    splashTransX = splashTransX - splashTransSpeed
    splashTransY = splashTransY - splashTransSpeed / 5
end

-- ***********************
-- HOWTO FUNCTIONS
-- ***********************
function howToDraw()
    love.graphics.draw(howTo, 50, 0, 0, 1, 1)
    love.graphics.draw(pushJ, 550, 500, 0, 0.5, 0.5)
end

function howToUpdate(dt)
    
    local down = love.keyboard.isDown
    if down("j") then
        gameLoadLevel(currentLevel)
        state = "game"
    end
end

-- ***********************
-- GAME FUNCTIONS
-- ***********************
local gameMusic = love.audio.newSource("assets/sounds/ZombiesAreComing.ogg")

-- Level loader handler
function gameLoadLevel(level)
    local levelData = levels[currentLevel]
    -- Set world meter size (in pixels)
    love.physics.setMeter(48)

    -- Load a map exported to Lua from Tiled
    map = sti(levelData.map, { "box2d" })

    -- Prepare physics world with horizontal and vertical gravity
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    -- Prepare collision objects
    map:box2d_init(world)
    world:setCallbacks(beginContact)

    -- Create a Custom Layerdddddd
    map:addCustomLayer("Sprite Layer", 4)

    -- Add data to Custom Layer
    spriteLayer = map.layers["Sprite Layer"]

    -- appending player
    myPlayer = Character(0, 0, "assets/images/sprite.png")
    spriteLayer.sprites = { player = myPlayer:draw() }

    -- draw entities
    local enemyCounter = 1
    for k, object in pairs(map.objects) do
        if object.name == "player" then
            player = spriteLayer.sprites.player
            player.body = love.physics.newBody(world, object.x, object.y, 'dynamic')
            player.body:setLinearDamping(10)
            player.body:setFixedRotation(true)
            player.shape = love.physics.newRectangleShape(14, 14)
            player.lives = playerLives
            player.fixture = love.physics.newFixture(player.body, player.shape)
            player.fixture:setUserData('Player')
        elseif object.name == "exit" then
            exit = {}
            exit.body = love.physics.newBody(world, object.x + object.width / 2, object.y + object.height / 2, 'static')
            exit.shape = love.physics.newRectangleShape(object.width, object.height)
            exit.fixture = love.physics.newFixture(exit.body, exit.shape)
            exit.fixture:setUserData('Exit')
        elseif object.type == "enemy" then
            local char = Character(object.x, object.y)
            local entity = { name = "enemy_" .. enemyCounter, sprite = '', sound = '', pos = { x = object.x, y = object.y }, vel = { x = 0.5, y = 0.5 } }
            table.insert(entities, entity)
            spriteLayer.sprites[entity.name] = char:draw()
            local charObj = spriteLayer.sprites[entity.name]
            charObj.body = love.physics.newBody(world, object.x, object.y, 'dynamic')
            charObj.body:setLinearDamping(10)
            charObj.body:setFixedRotation(true)
            charObj.shape = love.physics.newRectangleShape(object.width, object.height)
            charObj.fixture = love.physics.newFixture(charObj.body, charObj.shape)
            charObj.fixture:setUserData(entity.name)
            charObj.fixture:setRestitution(5)
            enemyCounter = enemyCounter + 1
        end
    end

    -- Draw callback for Custom Layer
    function spriteLayer:draw()
        for _, sprite in pairs(self.sprites) do
            local x = math.floor(sprite.x)
            local y = math.floor(sprite.y)
            love.graphics.draw(sprite.image, x, y)
        end
    end

    -- removes maps object layers
    map:removeLayer('objects')

    -- welcome sound
    local welcomeSound = love.audio.newSource("assets/sounds/Lets_go.wav", "static")
    welcomeSound:play()
    
    gameMusic:play()
    gameMusic:setVolume(0.5)
end


function levelUpdate(dt)
    -- update entities

    for _, entity in ipairs(entities) do
        updateMotion(entity)
    end

    local down = love.keyboard.isDown
    local up = love.keyreleased(key)

    local x, y = 0, 0
    local speed = 48
    if reload == false then
        if down("z", "up") and player.y > 8 then
            y = y - speed
            direction_player = 4
        end
        if down("s", "down") then
            y = y + speed
            direction_player = 2
        end
        if down("q", "left") and player.x > 8 then
            x = x - speed
            direction_player = 3
        end
        if down("d", "right") then
            x = x + speed
            direction_player = 1
        end
    end
    if down("r") then
        reload = true
        if nbPages < 10 then
            love.timer.sleep(1)
            nbPages = nbPages + 1
        end
    end
    player.body:applyForce(x, y)
    player.x = player.body:getX() - 8
    player.y = player.body:getY() - 8

    -- update bullets:
    local i, o
    for i, o in ipairs(bullets) do
        if o.dir == 1 then
            o.x = o.x + o.speed * dt
        elseif o.dir == 2 then
            o.y = o.y + o.speed * dt
        elseif o.dir == 3 then
            o.x = o.x - o.speed * dt
        elseif o.dir == 4 then
            o.y = o.y - o.speed * dt
        end
        local paperDistance = 50
        if (o.x < player.x - paperDistance) or (o.x > player.x + paperDistance)
                or (o.y < player.y - paperDistance) or (o.y > player.y + paperDistance) then
            table.remove(bullets, i)
        end
        for _, entity in ipairs(entities) do
            checkIfCollide(entity, o, bullets, i)
        end
    end
    -- updates routines
    map:update(dt)
    world:update(dt)
    
    -- splash music loop
    if gameMusic:isStopped() then
        gameMusic:play()
    end
    
end

-- ***********************
-- GAMEOVER FUNCTIONS
-- ***********************

function gameOverUpdate(dt)
    local down = love.keyboard.isDown
    if down("escape") then
        love.event.quit('restart')
    end
end

function gameOverDraw()
    love.graphics.draw(death,400, 300, 0, 1, 1)
    love.graphics.print('YOU DIED!', 100, 100)
    love.graphics.print("Appuyez sur l'échap bouton pour recommencer", 200, 200)
end

-- ***********************
-- GAMEWIN FUNCTIONS
-- ***********************

function gameWinUpdate(dt)
    local down = love.keyboard.isDown
    if down("escape") then
        love.event.quit('restart')
    end
end

function gameWinDraw()
    love.graphics.draw(winner,400, 300, 0, 1, 1)
    love.graphics.print('YOU ARE WINNER!', 100, 100)
    love.graphics.print("Appuyez sur l'échap bouton pour recommencer et faire encore mieux !", 200, 200)
end

function gameMorePageDraw()
    love.graphics.setColor(0, 255, 255, 255)
    love.graphics.print('Votre dossier est incomplet!', 100, 100)
end

-- ***********************
-- COLISION DETECTION
-- ***********************
function beginContact(a, b, coll)
    x, y = coll:getNormal()
    local idA = a:getUserData()
    local idB = b:getUserData()
    -- if something collide with the players
    if idA == 'Player' or idB == 'Player' then
        if idA == 'Exit' or idB == 'Exit' then
            if currentLevel < #levels then
                currentLevel = currentLevel + 1
                gameLoadLevel(currentLevel)
            else
                if nbPages == 35 then
                    state = "gamewin"
                else
                    state = "morepage"
                end
            end
        else
            -- play ennemy sound
            local enemy = nil
            if spriteLayer.sprites[idA] then
                enemy = spriteLayer.sprites[idA]
            elseif spriteLayer.sprites[idB] then
                enemy = spriteLayer.sprites[idB]
            end
            if enemy then
                local enemySound = love.audio.newSource(enemy.hitSound, 'static')
                enemySound:play()
                playerLives = playerLives - 1
                player.lives = playerLives
                if player.lives == 0 then
                    state = "gameover"
                end
            end
        end
    end
end
