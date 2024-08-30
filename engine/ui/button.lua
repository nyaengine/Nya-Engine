-- engine/ui/button.lua

local UIButton = {}
UIButton.__index = UIButton

function UIButton:new(params)
    local instance = {
        x = params.x or 0,
        y = params.y or 0,
        width = params.width or 100,
        height = params.height or 50,
        label = params.label or "Button",
        color = params.color or {0.8, 0.8, 0.8},
        onClick = params.onClick
    }
    setmetatable(instance, UIButton)
    return instance
end

function UIButton:update(dt)
    -- Button specific updates can go here
end

function UIButton:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.label, self.x, self.y + self.height / 4, self.width, "center")
end

function UIButton:isClicked(x, y)
    return x > self.x and x < (self.x + self.width) and y > self.y and y < (self.y + self.height)
end

return UIButton
