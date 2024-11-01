local Button = require("ui_button")  -- Ensure this is spelled and pathed correctly

local UI = {}
local ColorPicker = require("ui_color_picker")

function UI:init(engine)
    self.engine = engine
    self.buttons = {}
    self.activeObject = nil

    -- Create buttons for basic actions
    self:addButton("Add Object", 10, 10, function()
        local obj = self.engine:createObject()
        self.activeObject = obj
    end)

    self:addButton("Delete Object", 10, 50, function()
        if self.activeObject then
            self.engine.activeScene:removeObject(self.activeObject)
            self.activeObject = nil
        end
    end)

    -- Initialize the color picker for object colors
    self.colorPicker = ColorPicker:new(10, 100, function(color)
        if self.activeObject then
            self.activeObject.color = color
        end
    end)
end

function UI:addButton(label, x, y, action)
    table.insert(self.buttons, Button:new(label, x, y, action))
end

function UI:update(dt)
    -- Update buttons and color picker
    for _, button in ipairs(self.buttons) do button:update(dt) end
    self.colorPicker:update(dt)
end

function UI:render()
    for _, button in ipairs(self.buttons) do button:render() end
    self.colorPicker:render()
end

function UI:mousepressed(x, y, button)
    for _, btn in ipairs(self.buttons) do btn:mousepressed(x, y, button) end
    self.colorPicker:mousepressed(x, y, button)
end

return UI
