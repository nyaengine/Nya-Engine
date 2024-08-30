-- engine/ui/label.lua

local UILabel = {}
UILabel.__index = UILabel

function UILabel:new(params)
    local instance = {
        x = params.x or 0,
        y = params.y or 0,
        text = params.text or "Label",
        color = params.color or {1, 1, 1}
    }
    setmetatable(instance, UILabel)
    return instance
end

function UILabel:update(dt)
    -- Label specific updates can go here
end

function UILabel:draw()
    love.graphics.setColor(self.color)
    love.graphics.print(self.text, self.x, self.y)
end

return UILabel
