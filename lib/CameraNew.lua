Camera = {}
Camera.__index = Camera

function Camera:new()
    local cam = setmetatable({}, self)
    cam.x = 0
    cam.y = 0
    cam.scale = 1
    return cam
end

function Camera:set()
    love.graphics.push()
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
    love.graphics.pop()
end

function Camera:follow(target, screenWidth, screenHeight)
    self.x = target.x - (screenWidth / 2) + (target.width / 2)
    self.y = target.y - (screenHeight / 2) + (target.height / 2)
end

return Camera