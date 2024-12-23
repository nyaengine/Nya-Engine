local ButtonLibrary = {}
ButtonLibrary.__index = ButtonLibrary

-- Create a new button
function ButtonLibrary:new(x, y, width, height, label, onClick)
    local btn = {}
    setmetatable(btn, ButtonLibrary)

    btn.x = x or 0
    btn.y = y or 0
    btn.width = width or 100
    btn.height = height or 40
    btn.label = label or "Button"
    btn.onClick = onClick or function() end
    btn.isHovered = false

    return btn
end

-- Update button hover state based on mouse position
function ButtonLibrary:update(mouseX, mouseY)
    self.isHovered = mouseX >= self.x and mouseX <= self.x + self.width and
                     mouseY >= self.y and mouseY <= self.y + self.height
end

-- Check if the button is clicked
function ButtonLibrary:mousepressed(mouseX, mouseY, button)
    if button == 1 and self.isHovered then
        self.onClick() -- Trigger the button's onClick function
    end
end

-- Draw the button
function ButtonLibrary:draw()
    -- Button background
    if self.isHovered then
        love.graphics.setColor(0.7, 0.7, 0.7) -- Hover color
    else
        love.graphics.setColor(0.5, 0.5, 0.5) -- Default color
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Button border
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Button label
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.label, self.x, self.y + self.height / 4, self.width, "center")
end

return ButtonLibrary
