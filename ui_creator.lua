local UIManager = require("engine.ui.ui_manager")
local entity = require("engine.entity")
local engine = require("engine.engine")

local UICreator = {}
UICreator.__index = UICreator

function UICreator:new()
    local instance = {
        elements = {},           -- Stores the created UI elements
        selectedElement = nil,   -- Tracks the currently selected UI element
        mode = "select",         -- Mode: "select", "create_button", "create_label", "create_textbox", "create_particle_system"
        uiManager = UIManager,   -- Reference to the UI Manager
        panelWidth = 200,        -- Width of the UI side panel
        activeParticleSystem = nil, -- Store the currently active particle system for customization
        particleConfig = {       -- Default particle system configuration
            maxParticles = 200,
            emissionRate = 30,
            minLifetime = 0.5,
            maxLifetime = 1.5,
            startSize = 1,
            endSize = 0.5,
            startColor = {1, 0, 0, 1},
            endColor = {1, 1, 0, 0},
            spread = math.pi / 4,
            minSpeed = 50,
            maxSpeed = 100
        }
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
    self:drawButton("Create Entity", 10, 170, "entity")
    self:drawButton("Create Particle", 10, 210, "create_particle_system")
    self:drawButton("Select", 10, 250, "select")

    -- If particle system is active, show customization options
    if self.activeParticleSystem then
        self:drawParticleCustomizationPanel()
    end
end

function UICreator:drawButton(text, x, y, mode)
    love.graphics.setColor(self.mode == mode and {0.6, 0.6, 0.6} or {0.3, 0.3, 0.3})
    love.graphics.rectangle("fill", x, y, self.panelWidth - 20, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(text, x, y + 5, self.panelWidth - 20, "center")
end

function UICreator:drawParticleCustomizationPanel()
    local config = self.particleConfig
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Particle Settings", 10, 300, self.panelWidth, "center")

    -- Example customization fields (replace with more detailed customization)
    love.graphics.printf("Max Particles: " .. config.maxParticles, 10, 340, self.panelWidth, "left")
    love.graphics.printf("Emission Rate: " .. config.emissionRate, 10, 360, self.panelWidth, "left")
    love.graphics.printf("Min Speed: " .. config.minSpeed, 10, 380, self.panelWidth, "left")
    love.graphics.printf("Max Speed: " .. config.maxSpeed, 10, 400, self.panelWidth, "left")
    love.graphics.printf("Start Size: " .. config.startSize, 10, 420, self.panelWidth, "left")
    love.graphics.printf("End Size: " .. config.endSize, 10, 440, self.panelWidth, "left")

    -- You can add sliders or textboxes to adjust these values and apply changes in real-time
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
    elseif self.mode == "create_particle_system" then
        self:createParticleSystem(x, y)
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
        self.mode = "entity"
    elseif y >= 210 and y <= 240 then
        self.mode = "create_particle_system"
    elseif y >= 250 and y <= 280 then
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

function UICreator:createParticleSystem(x, y)
    -- Create a new particle system using the particle configuration
    local particleSystem = engine:createParticleSystem(love.graphics.newImage("assets/sprites/particle.png"), self.particleConfig)

    -- Set the active particle system for customization
    self.activeParticleSystem = particleSystem
    self.mode = "select" -- Switch to select mode after creating
end

return UICreator
