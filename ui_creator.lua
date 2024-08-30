-- ui_creator.lua

local UIManager = require("engine.ui.ui_manager")

local UICreator = {}
UICreator.__index = UICreator

function UICreator:new()
    local instance = {
        elements = {},           -- Stores the created UI elements
        selectedElement = nil,   -- Tracks the currently selected UI element
        mode = "select",         -- Mode: "select", "create_button", "create_label", "create_textbox"
        uiManager = UIManager,   -- Reference to the UI Manager
        panelWidth = 200         -- Width of the UI side panel
    }
    setmetatable(instance, UICreator)
    return instance
end

function UICreator:drawPanel()
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill", 0, 0, self.panelWidth, love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("UI Creator", 0, 10, self.panelWidth, "center")

    -- Draw mode buttons
    self:drawButton("Create Button", 10, 50, "create_button")
    self:drawButton("Create Label", 10, 90, "create_label")
    self:drawButton("Create TextBox", 10, 130, "create_textbox")
    self:drawButton("Select", 10, 170, "select")
end

function UICreator:drawButton(text, x, y, mode)
    love.graphics.setColor(self.mode == mode and {0.6, 0.6, 0.6} or {0.3, 0.3, 0.3})
    love.graphics.rectangle("fill", x, y, self.panelWidth - 20, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(text, x, y + 5, self.panelWidth - 20, "center")
end

function UICreator:update(dt)
    -- Update all UI elements
    self.uiManager:update(dt)
end

function UICreator:draw()
    -- Draw UI Creator panel
    self:drawPanel()
    
    -- Draw all UI elements on the canvas
    self.uiManager:draw()
end

function UICreator:mousepressed(x, y, button)
    -- If clicking on the panel, check button interactions
    if x < self.panelWidth then
        self:handlePanelClick(x, y)
        return
    end

    -- If in select mode, check for element selection
    if self.mode == "select" then
        self.uiManager:mousepressed(x, y, button)
        -- Check if an element was selected
        self.selectedElement = self:getClickedElement(x, y)
    elseif self.mode == "create_button" then
        self:createUIElement("button", x, y)
    elseif self.mode == "create_label" then
        self:createUIElement("label", x, y)
    elseif self.mode == "create_textbox" then
        self:createUIElement("textbox", x, y)
    end
end

function UICreator:handlePanelClick(x, y)
    if y >= 50 and y <= 80 then
        self.mode = "create_button"
    elseif y >= 90 and y <= 120 then
        self.mode = "create_label"
    elseif y >= 130 and y <= 160 then
        self.mode = "create_textbox"
    elseif y >= 170 and y <= 200 then
        self.mode = "select"
    end
end

function UICreator:getClickedElement(x, y)
    for _, element in ipairs(self.uiManager.elements) do
        if element.isClicked and element:isClicked(x, y) then
            return element
        end
    end
    return nil
end

function UICreator:createUIElement(type, x, y)
    if type == "button" then
        self.uiManager:addButton({
            x = x, y = y, width = 100, height = 40, label = "New Button",
            onClick = function() print("Button Created!") end
        })
    elseif type == "label" then
        self.uiManager:addLabel({
            x = x, y = y, text = "New Label"
        })
    elseif type == "textbox" then
        self.uiManager:addTextBox({
            x = x, y = y, width = 150, height = 30, placeholder = "Type here..."
        })
    end
    -- After creating, switch back to select mode
    self.mode = "select"
end

return UICreator
