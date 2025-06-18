-- ui.lua
local UI = {
    frames = {},
    activeFrame = nil
}

local Frame = require("lib.frame") -- Make sure this module exists

-- UI Elements
local UIList = {}
local frameProperties = {
    x = 50,
    y = 50,
    width = 250,
    height = 250,
    visible = true,
    color = {1, 1, 1, 1}
}

-- Button for creating new frames
local frameCreateBut = ButtonLibrary:new(0, 50, 100, 30, "Create Frame", function()
    local newFrame = Frame.new(
        frameProperties.x,
        frameProperties.y,
        frameProperties.width,
        frameProperties.height,
        frameProperties.visible
    )
    newFrame.color = frameProperties.color
    table.insert(UI.frames, newFrame)
    table.insert(UIList, "Frame " .. tostring(#UI.frames))
    UI.activeFrame = newFrame
end)

-- Frame property controls
local frameXTextbox = TextBox.new(200, 100, 50, 30, tostring(frameProperties.x))
local frameYTextbox = TextBox.new(200, 150, 50, 30, tostring(frameProperties.y))
local frameWidthTextbox = TextBox.new(200, 200, 50, 30, tostring(frameProperties.width))
local frameHeightTextbox = TextBox.new(200, 250, 50, 30, tostring(frameProperties.height))
local frameVisibleCheckbox = CheckboxLib.Checkbox.new(200, 300, 20, "Visible", frameProperties.visible)

-- Color picker for frame color
local frameColorPicker = {
    r = 1, g = 1, b = 1, a = 1,
    update = function(self, x, y)
        -- Simple color picker implementation
        if love.mouse.isDown(1) then
            local mx, my = love.mouse.getPosition()
            if mx >= 200 and mx <= 300 and my >= 350 and my <= 400 then
                self.r = (mx - 200) / 100
                self.g = (my - 350) / 50
                frameProperties.color = {self.r, self.g, self.b, self.a}
                if UI.activeFrame then
                    UI.activeFrame.color = frameProperties.color
                end
            end
        end
    end,
    draw = function(self)
        love.graphics.setColor(self.r, self.g, self.b, self.a)
        love.graphics.rectangle("fill", 200, 350, 100, 50)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Color Picker", 200, 330)
    end
}

function UI:load()
    -- Initialize default frame
    local defaultFrame = Frame.new(50, 50, 250, 250, true)
    table.insert(self.frames, defaultFrame)
    table.insert(UIList, "Frame 1")
    self.activeFrame = defaultFrame
    
    -- Set up textbox callbacks
    frameXTextbox:setCallback(function(text)
        frameProperties.x = tonumber(text) or 50
    end)
    
    frameYTextbox:setCallback(function(text)
        frameProperties.y = tonumber(text) or 50
    end)
    
    frameWidthTextbox:setCallback(function(text)
        frameProperties.width = tonumber(text) or 250
    end)
    
    frameHeightTextbox:setCallback(function(text)
        frameProperties.height = tonumber(text) or 250
    end)
    
    frameVisibleCheckbox:setOnToggle(function(checked)
        frameProperties.visible = checked
        if self.activeFrame then
            self.activeFrame.visible = checked
        end
    end)
end

function UI:update(dt)
    -- Update active frame properties if one is selected
    if self.activeFrame then
        if frameXTextbox.focused then
            self.activeFrame.x = tonumber(frameXTextbox.text) or self.activeFrame.x
        end
        
        if frameYTextbox.focused then
            self.activeFrame.y = tonumber(frameYTextbox.text) or self.activeFrame.y
        end
        
        if frameWidthTextbox.focused then
            self.activeFrame.width = tonumber(frameWidthTextbox.text) or self.activeFrame.width
        end
        
        if frameHeightTextbox.focused then
            self.activeFrame.height = tonumber(frameHeightTextbox.text) or self.activeFrame.height
        end
    end
    
    -- Update UI elements
    frameCreateBut:update(love.mouse.getPosition())
    frameXTextbox:update(dt)
    frameYTextbox:update(dt)
    frameWidthTextbox:update(dt)
    frameHeightTextbox:update(dt)
    frameVisibleCheckbox:update(dt)
    frameColorPicker:update(dt)
end

function UI:draw()
    -- Draw all frames
    for _, frame in ipairs(self.frames) do
        if frame.visible then
            frame:draw()
        end
    end
    
    -- Draw UI creation panel
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", 0, 0, 350, love.graphics.getHeight())
    
    -- Draw controls
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("UI Builder", 10, 10)
    
    frameCreateBut:draw()
    
    love.graphics.print("Frame Properties", 10, 80)
    love.graphics.print("X:", 10, 110)
    frameXTextbox:draw()
    love.graphics.print("Y:", 10, 160)
    frameYTextbox:draw()
    love.graphics.print("Width:", 10, 210)
    frameWidthTextbox:draw()
    love.graphics.print("Height:", 10, 260)
    frameHeightTextbox:draw()
    
    frameVisibleCheckbox:draw()
    frameColorPicker:draw()
    
    -- Draw frame list
    love.graphics.print("Frames:", 10, 420)
    for i, frameName in ipairs(UIList) do
        local y = 450 + (i-1)*20
        love.graphics.print(frameName, 10, y)
        
        -- Highlight selected frame
        if self.frames[i] == self.activeFrame then
            love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
            love.graphics.rectangle("fill", 5, y-2, 120, 18)
            love.graphics.setColor(1, 1, 1)
        end
    end
end

function UI:mousepressed(x, y, button)
    -- Check if a frame was clicked
    for i, frame in ipairs(self.frames) do
        if x >= frame.x and x <= frame.x + frame.width and
           y >= frame.y and y <= frame.y + frame.height then
            self.activeFrame = frame
            -- Update properties to match selected frame
            frameXTextbox.text = tostring(frame.x)
            frameYTextbox.text = tostring(frame.y)
            frameWidthTextbox.text = tostring(frame.width)
            frameHeightTextbox.text = tostring(frame.height)
            frameVisibleCheckbox:setChecked(frame.visible)
            frameProperties.color = frame.color or {1, 1, 1, 1}
            return
        end
    end
    
    -- Check if a frame name was clicked in the list
    for i = 1, #UIList do
        local listY = 450 + (i-1)*20
        if x >= 10 and x <= 130 and y >= listY and y <= listY+16 then
            self.activeFrame = self.frames[i]
            -- Update properties to match selected frame
            frameXTextbox.text = tostring(self.activeFrame.x)
            frameYTextbox.text = tostring(self.activeFrame.y)
            frameWidthTextbox.text = tostring(self.activeFrame.width)
            frameHeightTextbox.text = tostring(self.activeFrame.height)
            frameVisibleCheckbox:setChecked(self.activeFrame.visible)
            frameProperties.color = self.activeFrame.color or {1, 1, 1, 1}
            return
        end
    end
    
    -- Handle UI element clicks
    frameCreateBut:mousepressed(x, y, button)
    frameXTextbox:mousepressed(x, y, button)
    frameYTextbox:mousepressed(x, y, button)
    frameWidthTextbox:mousepressed(x, y, button)
    frameHeightTextbox:mousepressed(x, y, button)
    frameVisibleCheckbox:mousepressed(x, y, button)
end

function UI:textinput(text)
    frameXTextbox:textinput(text)
    frameYTextbox:textinput(text)
    frameWidthTextbox:textinput(text)
    frameHeightTextbox:textinput(text)
end

return UI