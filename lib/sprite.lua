local Sprite = {}
Sprite.__index = Sprite

-- Constructor for creating a new sprite
function Sprite:new(filePath, x, y, width, height)
    local sprite = setmetatable({}, Sprite)
    sprite.image = love.graphics.newImage(filePath)
    sprite.x = x or 0
    sprite.y = y or 0
    sprite.width = width or sprite.image:getWidth()
    sprite.height = height or sprite.image:getHeight()
    return sprite
end

-- Draw the sprite
function Sprite:draw()
    love.graphics.draw(
        self.image,
        self.x,
        self.y,
        0, -- Rotation
        self.width / self.image:getWidth(),
        self.height / self.image:getHeight()
    )
end

-- Update the sprite's position
function Sprite:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Update the sprite's size
function Sprite:setSize(width, height)
    self.width = width
    self.height = height
end

-- Get the sprite's bounding box for collision or selection
function Sprite:getBoundingBox()
    return self.x, self.y, self.width, self.height
end

-- Check if a point is inside the sprite's bounding box
function Sprite:isPointInside(px, py)
    return px >= self.x and px <= self.x + self.width and
           py >= self.y and py <= self.y + self.height
end

return Sprite