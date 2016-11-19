Object = require "lib.classic"
Projectile = Object:extend()

function Projectile:new(abs,ord,vit,direction,img)
  local pjct = {}
  setmetatable(pjct,Projectile)
  self.x = abs
  self.y = ord
  self.vitesse = vit
  self.image = img
  self.dir = direction

end

function Projectile:draw()
  return {
            x = self.x,
            y = self.y,
            dir = self.dir,
            speed = self.vitesse
        }
end

