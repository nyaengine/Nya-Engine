local TextBox = {}
TextBox.__index = TextBox

function TextBox.new(x, y, width, height, placeholder, bgColor, textColor)
    local self = setmetatable({}, TextBox)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = ""
    self.placeholder = placeholder or "Enter text..."
    self.focused = false
    self.cursorPos = #self.text + 1
    self.bgColor = bgColor or preferences.getColor("textbox", "background")
    self.textColor = textColor or preferences.getColor("textbox", "color")
    self.font = love.graphics.getFont()
    return self
end

function TextBox:isFocused()
    return self.focused
end

function TextBox:setPosition(x, y)
    self.x = x
    self.y = y
end

function TextBox:setCallback(callback)
    self.callback = callback
end

function TextBox:update(dt)
    self.bgColor = preferences.getColor("textbox", "background")
    self.textColor = preferences.getColor("textbox", "textColor")

    if self.focused and love.keyboard.isDown("backspace") then
        if #self.text > 0 then
            self.text = self.text:sub(1, -2)
            self.cursorPos = #self.text + 1
        end
    end
end

function TextBox:setFont(font)
    self.font = font
end

function TextBox:draw()
    -- pull latest theme colors every frame
    local bg = self.bgColor or preferences.getColor("textbox", "background")
    local textCol = self.textColor or preferences.getColor("textbox", "textColor")

    love.graphics.setColor(bg)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(textCol)
    love.graphics.setFont(self.font)

    local textToDraw = self.text ~= "" and self.text or self.placeholder
    love.graphics.print(textToDraw, self.x + 5, self.y + (self.height / 2) - 6)
end

-- Use keypressed for discrete input instead of getPressed
function TextBox:textInputHandler(text)
    if text:len() == 1 then
        self.text = self.text:sub(1, self.cursorPos - 1) .. text .. self.text:sub(self.cursorPos)
        self.cursorPos = self.cursorPos + 1
    end
end

-- Attach text input handling (see `love.textinput`)
function TextBox:textinput(text)
    if self.focused then
        self:textInputHandler(text)  -- Pass `self` to the handler
        if self.callback then
            self.callback(self.text)
        end
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
