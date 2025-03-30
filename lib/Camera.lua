local Camera = {}
Camera.__index = Camera

-- Constructor
function Camera:new(x, y, scale)
    local camera = {
        x = x or 0,
        y = y or 0,
        scale = scale or 1,
        offsetX = love.graphics.getWidth() / 2,
        offsetY = love.graphics.getHeight() / 2
    }
    setmetatable(camera, self)
    return camera
end

-- Set the camera position
function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Move the camera by a delta
function Camera:move(dx, dy)
    self.x = self.x + dx / self.scale
    self.y = self.y + dy / self.scale
end

-- Set the camera scale
function Camera:setScale(scale)
    self.scale = scale
end

-- Zoom the camera by a factor
function Camera:zoom(factor)
    self.scale = self.scale * factor
end

-- Focus the camera on a specific object
function Camera:focus(object)
    if object then
        self.x = object.x + object.width / 2 - self.offsetX / self.scale
        self.y = object.y + object.height / 2 - self.offsetY / self.scale
    end
end

-- Apply the camera transformation
function Camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
end

-- Reset the camera transformation
function Camera:reset()
    love.graphics.pop()
end

return Camera
