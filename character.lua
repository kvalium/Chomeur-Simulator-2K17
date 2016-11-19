Object  = require "lib.classic"

Character = Object:extend()

-- constructor

function Character:new(x, y, sprite, sound)
    self.x = x or 0
    self.y = y or 0
    self.sprite = love.graphics.newImage(sprite)
    self.sound = sound or 'assets/sounds/goutte-deau.wav'
end

-- draw the Character 
function Character:draw()
  return {
      image = self.sprite,
      x = self.x,
      y = self.y,
      sound = self.sound
  }
end


-- GETTERS & SETTERS

function Character:getX() return self.x end
function Character:setX(x) self.x = x end

function Character:getY() return self.y end
function Character:setY() self.y = y end

function Character:getSprite() return self.sprite end
