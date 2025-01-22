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
    -- To be overridden by subclasses
end

function GameObject:containsPoint(px, py)
    return px >= self.x and px <= (self.x + self.width) and
           py >= self.y and py <= (self.y + self.height)
end

return GameObject