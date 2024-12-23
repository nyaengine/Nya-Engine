local MobileControls = {}

-- Joystick properties
MobileControls.joystick = {
    x = 100, y = love.graphics.getHeight() - 150, radius = 50, innerRadius = 30,
    touchID = nil, dx = 0, dy = 0
}

-- Buttons properties
MobileControls.buttons = {
    {x = love.graphics.getWidth() - 100, y = love.graphics.getHeight() - 150, radius = 40, label = "A", touchID = nil},
    {x = love.graphics.getWidth() - 180, y = love.graphics.getHeight() - 200, radius = 40, label = "B", touchID = nil},
}

-- Draw function
function MobileControls:draw()
    -- Draw joystick
    love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
    love.graphics.circle("fill", self.joystick.x, self.joystick.y, self.joystick.radius)
    love.graphics.setColor(0.8, 0.8, 0.8, 0.7)
    love.graphics.circle("fill", self.joystick.x + self.joystick.dx, self.joystick.y + self.joystick.dy, self.joystick.innerRadius)
    
    -- Draw buttons
    for _, button in ipairs(self.buttons) do
        love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
        love.graphics.circle("fill", button.x, button.y, button.radius)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(button.label, button.x - button.radius / 2, button.y - 8, button.radius, "center")
    end
end

-- Update joystick movement
function MobileControls:updateTouches(touches)
    -- Reset joystick movement
    self.joystick.dx, self.joystick.dy = 0, 0
    
    -- Process touches
    for _, touch in ipairs(touches) do
        local tx, ty, id = touch.x, touch.y, touch.id
        
        -- Joystick control
        if self.joystick.touchID == nil or self.joystick.touchID == id then
            local dist = math.sqrt((tx - self.joystick.x)^2 + (ty - self.joystick.y)^2)
            if dist <= self.joystick.radius then
                self.joystick.touchID = id
                local angle = math.atan2(ty - self.joystick.y, tx - self.joystick.x)
                self.joystick.dx = math.min(dist, self.joystick.radius) * math.cos(angle)
                self.joystick.dy = math.min(dist, self.joystick.radius) * math.sin(angle)
            end
        end
        
        -- Button controls
        for _, button in ipairs(self.buttons) do
            local dist = math.sqrt((tx - button.x)^2 + (ty - button.y)^2)
            if dist <= button.radius then
                button.touchID = id
            end
        end
    end
end

-- Handle touch released
function MobileControls:touchReleased(id)
    if self.joystick.touchID == id then self.joystick.touchID = nil end
    for _, button in ipairs(self.buttons) do
        if button.touchID == id then button.touchID = nil end
    end
end

-- API to get joystick values
function MobileControls:getJoystick()
    return self.joystick.dx / self.joystick.radius, self.joystick.dy / self.joystick.radius
end

-- API to check if a button is pressed
function MobileControls:isButtonPressed(label)
    for _, button in ipairs(self.buttons) do
        if button.label == label and button.touchID ~= nil then
            return true
        end
    end
    return false
end

return MobileControls
