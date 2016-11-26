Object = require "lib.classic"

Character = Object:extend()

local assetSpritesFolder = 'assets/images/'
local assetSoundsFolder = 'assets/sounds/'

local badAssets = {
    { sprite = 'fantome.png', hitSound = 'fantome.wav', deathSound = 'pain6.wav' },
    { sprite = 'scarabee.png', hitSound = 'Chipster.wav', deathSound = '8.ogg' },
    { sprite = 'souris.png', hitSound = 'picopico.wav', deathSound = 'pain6.wav' },
    { sprite = 'pumkin.png', hitSound = 'picopico.wav', deathSound = 'pain6.wav' },
    { sprite = 'bat.png', hitSound = 'picopico.wav', deathSound = 'pain6.wav' },
    { sprite = 'skeleton.png', hitSound = 'picopico.wav', deathSound = 'pain6.wav' },
    { sprite = 'pumkin.png', hitSound = 'picopico.wav', deathSound = 'pain6.wav' },
    { sprite = 'troll.png', hitSound = 'picopico.wav', deathSound = 'pain6.wav' }
}


-- constructor

function Character:new(x, y, sprite)
    local chosen = math.random(#badAssets)
    self.x = x
    self.y = y
    self.sprite = love.graphics.newImage(sprite or assetSpritesFolder  .. badAssets[chosen].sprite)
    self.hitSound = assetSoundsFolder .. badAssets[chosen].hitSound
    self.deathSound = assetSoundsFolder .. badAssets[chosen].deathSound
end

-- draw the Character 
function Character:draw()
    return {
        image = self.sprite,
        x = self.x - 8,
        y = self.y - 8,
        hitSound = self.hitSound,
        deathSound = self.deathSound
    }
end


-- GETTERS & SETTERS

function Character:getX() return self.x end

function Character:setX(x) self.x = x end

function Character:getY() return self.y end

function Character:setY() self.y = y end

function Character:getSprite() return self.sprite end
