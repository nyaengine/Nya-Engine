local Button = {}
Button.__index = Button

function Button:new(label, x, y, action)
    local btn = setmetatable({}, Button)
    btn.label = label
    btn.x = x
    btn.y = y
    btn.width = 100
    btn.height = 30
    btn.color = {0.9, 0.7, 0.9}  -- Cute pastel pink
    btn.action = action
    return btn
end

function Button:update(dt)
    -- Placeholder for button hover effects or animations
end

function Button:render()
    -- Draw button with rounded corners
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 10, 10)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.label, self.x, self.y + 8, self.width, "center")
end

function Button:mousepressed(x, y, button)
    if button == 1 and x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height then
        self.action()
    end
end

return Button