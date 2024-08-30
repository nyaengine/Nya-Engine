-- engine/camera.lua

local Camera = {}
Camera.__index = Camera

function Camera:new()
    local instance = {
        x = 0,
        y = 0,
        scale = 1,        -- Zoom level; 1 means 100% (no zoom)
        target = nil,     -- Optional target to follow
        bounds = nil      -- Optional bounds to limit the camera's movement {xMin, yMin, xMax, yMax}
    }
    setmetatable(instance, Camera)
    return instance
end

function Camera:setPosition(x, y)
    self.x = x
    self.y = y
    self:applyBounds()
end

function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
    self:applyBounds()
end

function Camera:setScale(scale)
    self.scale = math.max(scale, 0.1)  -- Prevent zooming too far out
end

function Camera:zoom(factor)
    self.scale = self.scale * factor
    self.scale = math.max(self.scale, 0.1)  -- Prevent zooming too far out
end

function Camera:setTarget(target)
    self.target = target
end

function Camera:setBounds(xMin, yMin, xMax, yMax)
    self.bounds = {xMin = xMin, yMin = yMin, xMax = xMax, yMax = yMax}
    self:applyBounds()
end

function Camera:applyBounds()
    if self.bounds then
        self.x = math.max(self.bounds.xMin, math.min(self.x, self.bounds.xMax))
        self.y = math.max(self.bounds.yMin, math.min(self.y, self.bounds.yMax))
    end
end

function Camera:update(dt)
    -- If a target is set, follow it
    if self.target then
        self:setPosition(self.target.x - love.graphics.getWidth() / 2, self.target.y - love.graphics.getHeight() / 2)
    end
end

function Camera:attach()
    -- Apply the camera transformations
    love.graphics.push()
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
    -- Revert to the previous graphics state
    love.graphics.pop()
end

return Camera
