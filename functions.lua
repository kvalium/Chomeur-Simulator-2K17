--
-- Prints debug information on objects
--
function printDebug(spriteLayer, entities, player, exit)
    -- Draw Collision Map
    love.graphics.setColor(255, 0, 0, 50)
    map:box2d_draw()

    -- player debug
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.polygon("line", player.body:getWorldPoints(player.shape:getPoints()))
    love.graphics.print(math.floor(player.x) .. ',' .. math.floor(player.y), player.x - 16, player.y - 16)

    -- exit debug
    love.graphics.setColor(0, 255, 0)
    love.graphics.polygon("line", exit.body:getWorldPoints(exit.shape:getPoints()))
    love.graphics.print(math.floor(exit.body:getX()) .. ',' .. math.floor(exit.body:getY()), exit.body:getX() - 16, exit.body:getY() - 16)

    -- entities debug
    love.graphics.setColor(255, 0, 0, 255)
    for _, entity in ipairs(entities) do
        if spriteLayer.sprites[entity.name] then
            local badGuy = spriteLayer.sprites[entity.name]
            if not badGuy.body:isDestroyed() then
                love.graphics.polygon("line", badGuy.body:getWorldPoints(badGuy.shape:getPoints()))
                love.graphics.print(math.floor(badGuy.x) .. ',' .. math.floor(badGuy.y), badGuy.x - 16, badGuy.y - 16)
            end
        end
    end

    love.graphics.setColor(255, 255, 255, 255)
end

--
-- Prints player's HUD
--
function printHud(player, nb_pages)
    love.graphics.setColor(0, 100, 100, 200)
    love.graphics.rectangle('fill', player.x - 300, player.y + 130, 1000, 1000)
    love.graphics.setColor(0, 0, 0, 255)

    love.graphics.print("Dossier pôle emplois :" .. nb_pages, player.x - 190, player.y + 135)
    love.graphics.print('Lives ' .. player.lives, player.x + 120, player.y + 135)

    love.graphics.setColor(255, 255, 255, 255)
end

