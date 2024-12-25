-- textbox.lua
local TextBox = {}
TextBox.__index = TextBox

function TextBox.new(x, y, width, height, placeholder)
    local self = setmetatable({}, TextBox)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = ""
    self.placeholder = placeholder or "Enter text..."
    self.focused = false
    self.cursorPos = #self.text + 1
    return self
end

function TextBox:update(dt)
    if self.focused then
        -- Handle text input
        if love.keyboard.isDown("backspace") then
            if #self.text > 0 then
                self.text = self.text:sub(1, -2)
                self.cursorPos = #self.text + 1
            end
        end

        for _, key in ipairs(love.keyboard.getPressed()) do
            if key:len() == 1 then
                self.text = self.text:sub(1, self.cursorPos - 1) .. key .. self.text:sub(self.cursorPos)
                self.cursorPos = self.cursorPos + 1
            end
        end
    end
end

function TextBox:draw()
    -- Draw the textbox background
    love.graphics.setColor(1, 1, 1) -- White color for background
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw the text
    love.graphics.setColor(0, 0, 0) -- Black color for text
    if self.text == "" then
        love.graphics.print(self.placeholder, self.x + 5, self.y + (self.height / 2) - 6)
    else
        love.graphics.print(self.text, self.x + 5, self.y + (self.height / 2) - 6)
    end
end

function TextBox:mousepressed(x, y, button, istouch, presses)
    if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
        self.focused = true
    else
        self.focused = false
    end
end

return TextBox