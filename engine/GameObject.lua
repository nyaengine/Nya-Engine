GameObject = {}
GameObject.__index = GameObject

function GameObject:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Default properties
    o.x = o.x or 0
    o.y = o.y or 0
    o.width = o.width or 0
    o.height = o.height or 0

    return o
end

function GameObject:update(dt)
    -- To be overridden by subclasses
end

function GameObject:draw()
    if self.texture then
        -- Calculate scaling factors based on the desired width and height
        local scaleX = self.width / self.texture:getWidth()
        local scaleY = self.height / self.texture:getHeight()
        
        -- Draw the texture with scaling applied
        love.graphics.draw(self.texture, self.x, self.y, 0, scaleX, scaleY)
    else
        love.graphics.setColor(1, 1, 1) -- white color for the square
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
end

function GameObject:isClicked(x, y)
    return x >= self.x and x <= (self.x + self.width) and
           y >= self.y and y <= (self.y + self.height)
end

return GameObject