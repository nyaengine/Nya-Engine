local GameObject = {}
GameObject.__index = GameObject

function GameObject:new(x, y, width, height)
    local obj = setmetatable({}, GameObject)
    obj.x = x or 0
    obj.y = y or 0
    obj.width = width or 32
    obj.height = height or 32
    obj.color = {1, 1, 1}  -- Default color is white
    return obj
end

function GameObject:update(dt)
    -- Placeholder for object update logic
end

function GameObject:render()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function GameObject:destroy()
    -- Empty destroy method for base GameObject
end

return GameObject
