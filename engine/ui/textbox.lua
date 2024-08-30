-- engine/ui/textbox.lua

local UITextBox = {}
UITextBox.__index = UITextBox

function UITextBox:new(params)
    local instance = {
        x = params.x or 0,
        y = params.y or 0,
        width = params.width or 200,
        height = params.height or 30,
        text = "",
        color = params.color or {1, 1, 1},
        textColor = params.textColor or {0, 0, 0},
        focused = false,
        placeholder = params.placeholder or "Enter text..."
    }
    setmetatable(instance, UITextBox)
    return instance
end

function UITextBox:update(dt)
    -- Update logic for the text box can go here (e.g., cursor blinking)
end

function UITextBox:draw()
    -- Draw the text box background
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)

    -- Draw the text
    love.graphics.setColor(self.textColor)
    local displayText = self.text
    if displayText == "" and not self.focused then
        -- Show placeholder text when empty and not focused
        love.graphics.setColor(0.6, 0.6, 0.6)
        displayText = self.placeholder
    end
    love.graphics.printf(displayText, self.x + 5, self.y + (self.height / 4), self.width - 10, "left")
end

function UITextBox:mousepressed(x, y, button)
    if button == 1 then
        -- Check if the click is within the textbox bounds
        self.focused = x > self.x and x < (self.x + self.width) and y > self.y and y < (self.y + self.height)
    end
end

function UITextBox:textinput(t)
    if self.focused then
        self.text = self.text .. t
    end
end

function UITextBox:keypressed(key)
    if self.focused then
        if key == "backspace" then
            -- Remove the last character from the text
            self.text = self.text:sub(1, -2)
        end
    end
end

return UITextBox
