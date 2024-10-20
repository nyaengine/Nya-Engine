local checkbox = {}
checkbox.__index = checkbox

function checkbox:new(params)
    local instance = setmetatable({}, checkbox)
    instance.params = params
    local val = false
    instance.val = val
end

function checkbox:toggle()
    self.val = not self.val
end

function checkbox:__tostring()
    return self.val and "checked" or "unchecked"
end

function checkbox:__eq(other)
    return self.val == other.val
end

function checkbox:draw()
    love.graphics.rectangle("line", 100, 100, 50, 50)
    if self.val ==  true then
        love.graphics.rectangle("fill", 100, 100, 50, 50)
    end
end

return checkbox