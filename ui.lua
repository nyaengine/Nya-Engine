local UI = {}
local Button = require("ui_button")
local ColorPicker = require("ui_color_picker")
local Slider = require("ui_slider")  -- New slider component for adjustable physics properties

-- Constants for sidebar dimensions and positions
local SIDEBAR_WIDTH = 200
local SIDEBAR_ANIMATION_SPEED = 500  -- Pixels per second

function UI:init(engine)
    self.engine = engine
    self.buttons = {}
    self.sliders = {}  -- New table to hold physics sliders
    self.activeObject = nil

    -- Sidebar state
    self.sidebarVisible = true
    self.sidebarX = 0  -- Current X position of the sidebar
    self.targetSidebarX = 0  -- Target X position for animation

    -- Toggle button (always visible)
    self.toggleButton = Button:new("≡", SIDEBAR_WIDTH, 10, function()
        self.sidebarVisible = not self.sidebarVisible
        if self.sidebarVisible then
            self.targetSidebarX = 0
        else
            self.targetSidebarX = -SIDEBAR_WIDTH
        end
    end, 40, 40)  -- Width and height for the toggle button

    -- Create buttons for basic actions inside the sidebar
    self:addButton("Add Object", 10, 60, function()
        local obj = self.engine:createObject()
        self.activeObject = obj
        self:initializePhysics(obj)  -- Initialize physics properties
    end)

    self:addButton("Delete Object", 10, 100, function()
        if self.activeObject then
            self.engine.activeScene:removeObject(self.activeObject)
            self.activeObject = nil
        end
    end)

    -- Initialize the color picker for object colors inside the sidebar
    self.colorPicker = ColorPicker:new(10, 150, function(color)
        if self.activeObject then
            self.activeObject.color = color
        end
    end)

    -- Add physics customization sliders
    self:addPhysicsSliders()
end

function UI:initializePhysics(obj)
    -- Set default physics properties for new objects
    obj.physics = obj.physics or {}
    obj.physics.mass = obj.physics.mass or 1
    obj.physics.gravity = obj.physics.gravity or 9.8
    obj.physics.friction = obj.physics.friction or 0.5
    obj.physics.bounce = obj.physics.bounce or 0.3
end

function UI:addButton(label, x, y, action, width, height)
    width = width or 100
    height = height or 30
    table.insert(self.buttons, Button:new(label, x, y, action, width, height))
end

function UI:addPhysicsSliders()
    -- Physics customization sliders, added at specific positions
    self.sliders.mass = Slider:new("Mass", 10, 250, 1, 20, function(value)
        if self.activeObject then self.activeObject.physics.mass = value end
    end)
    
    self.sliders.gravity = Slider:new("Gravity", 10, 290, 0, 20, function(value)
        if self.activeObject then self.activeObject.physics.gravity = value end
    end)
    
    self.sliders.friction = Slider:new("Friction", 10, 330, 0, 1, function(value)
        if self.activeObject then self.activeObject.physics.friction = value end
    end)
    
    self.sliders.bounce = Slider:new("Bounce", 10, 370, 0, 1, function(value)
        if self.activeObject then self.activeObject.physics.bounce = value end
    end)
end

function UI:update(dt)
    -- Update sidebar position with animation
    if self.sidebarX ~= self.targetSidebarX then
        local direction = self.targetSidebarX > self.sidebarX and 1 or -1
        self.sidebarX = self.sidebarX + direction * SIDEBAR_ANIMATION_SPEED * dt
        -- Clamp to target position
        if (direction == 1 and self.sidebarX > self.targetSidebarX) or
           (direction == -1 and self.sidebarX < self.targetSidebarX) then
            self.sidebarX = self.targetSidebarX
        end
    end

    -- Update buttons and color picker only if sidebar is visible
    if self.sidebarVisible or self.sidebarX > -SIDEBAR_WIDTH then
        for _, button in ipairs(self.buttons) do
            button:update(dt)
        end
        self.colorPicker:update(dt)
    end

    -- Always update the toggle button
    self.toggleButton:update(dt)
end

function UI:render()
    -- Render sidebar background
    love.graphics.setColor(0.5, 0, 0.5, 0.9)  -- Light pastel color
    love.graphics.rectangle("fill", self.sidebarX, 0, SIDEBAR_WIDTH, love.graphics.getHeight())

    -- Render sidebar contents only if visible or partially visible (during animation)
    if self.sidebarVisible or self.sidebarX > -SIDEBAR_WIDTH then
        -- Translate graphics for sidebar position
        love.graphics.push()
        love.graphics.translate(self.sidebarX, 0)

        -- Render UI title
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(love.graphics.getFont() or love.graphics.newFont(14))
        love.graphics.printf("Nya Engine Editor", 10, 10, SIDEBAR_WIDTH - 20, "center")

        -- Render all buttons
        for _, button in ipairs(self.buttons) do
            button:render()
        end

        -- Render color picker
        self.colorPicker:render()

        -- Render physics sliders if an object is selected
        if self.activeObject then
            for _, slider in pairs(self.sliders) do
                slider:render()
            end
        end

        love.graphics.pop()
    end

    -- Render toggle button
    self.toggleButton:render()
end

function UI:mousepressed(x, y, button)
    -- Handle toggle button first (always interactive)
    self.toggleButton:mousepressed(x, y, button)

    -- Handle sidebar interactions only if sidebar is visible or during animation
    if (self.sidebarVisible or self.sidebarX > -SIDEBAR_WIDTH) then
        for _, btn in ipairs(self.buttons) do
            btn:mousepressed(x, y, button)
        end
        self.colorPicker:mousepressed(x, y, button)
    end
end

function UI:keypressed(key)
    if self.sidebarVisible then
        for _, btn in ipairs(self.buttons) do
            btn:keypressed(key)
        end
        self.colorPicker:keypressed(key)

        -- Handle slider interactions if an object is selected
        if self.activeObject then
            for _, slider in pairs(self.sliders) do
                slider:mousepressed(x, y, button)
            end
        end
    end
end

function UI:mousereleased(x, y, button)
    if self.activeObject then
        for _, slider in pairs(self.sliders) do
            slider:mousereleased(x, y, button)
        end
    end
end

function UI:mousemoved(x, y, dx, dy)
    if self.activeObject then
        for _, slider in pairs(self.sliders) do
            slider:mousemoved(x, y, dx, dy)
        end
    end
end

return UI
