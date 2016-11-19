Object  = require "lib.classic"

BadGuy = Object:extend()

function BadGuy:new(x, y)
    self.x = x or 0
    self.y = y or 0
end