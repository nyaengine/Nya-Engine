local Camera = {}
Camera.__index = Camera

function Camera:new()
    local cam = setmetatable({}, Camera)
    cam.x = 0        -- Camera position X
    cam.y = 0        -- Camera position Y
    cam.scale = 1    -- Zoom level
    cam.target = nil -- The object the camera follows, if any
    return cam
end

function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Camera:setZoom(zoom)
    self.scale = zoom
end

function Camera:setTarget(target)
    self.target = target
end

function Camera:update(dt)
    -- If there's a target, follow it smoothly
    if self.target then
        local targetX, targetY = self.target.x, self.target.y
        local lerpSpeed = 3 * dt
        self.x = self.x + (targetX - self.x) * lerpSpeed
        self.y = self.y + (targetY - self.y) * lerpSpeed
    end
end

function Camera:apply()
    -- Apply translation and scaling
    love.graphics.push()
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:reset()
    love.graphics.pop()
end

return Camera
