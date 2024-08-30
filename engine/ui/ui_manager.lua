-- engine/ui/ui_manager.lua
local UIButton = require("engine.ui.button")
local UILabel = require("engine.ui.label")
local UITextBox = require("engine.ui.textbox")

local UIManager = {
    elements = {}
}

function UIManager:addButton(params)
    local button = UIButton:new(params)
    table.insert(self.elements, button)
    return button
end

function UIManager:addLabel(params)
    local label = UILabel:new(params)
    table.insert(self.elements, label)
    return label
end

function UIManager:addTextBox(params)
    local textbox = UITextBox:new(params)
    table.insert(self.elements, textbox)
    return textbox
end

function UIManager:update(dt)
    for _, element in ipairs(self.elements) do
        element:update(dt)
    end
end

function UIManager:draw()
    for _, element in ipairs(self.elements) do
        element:draw()
    end
end

function UIManager:mousepressed(x, y, button)
    for _, element in ipairs(self.elements) do
        if element.mousepressed then
            element:mousepressed(x, y, button)
        end
    end
end

function UIManager:textinput(text)
    for _, element in ipairs(self.elements) do
        if element.textinput then
            element:textinput(text)
        end
    end
end

function UIManager:keypressed(key)
    for _, element in ipairs(self.elements) do
        if element.keypressed then
            element:keypressed(key)
        end
    end
end

return UIManager
