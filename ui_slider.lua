local Slider = {}
Slider.__index = Slider

function Slider:new(label, x, y, min, max, callback)
    local slider = setmetatable({}, Slider)
    slider.label = label
    slider.x = x
    slider.y = y
    slider.min = min
    slider.max = max
    slider.value = min
    slider.callback = callback
    slider.width = 150
    slider.height = 10
    slider.handleWidth = 10
    slider.dragging = false  -- Track if the handle is being dragged
    return slider
end

function Slider:update(dt)
    -- Optionally add any effects for updating
end

function Slider:render()
    -- Draw slider background
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Calculate handle position based on the slider value
    local handleX = self.x + (self.width - self.handleWidth) * ((self.value - self.min) / (self.max - self.min))
    love.graphics.setColor(0.9, 0.7, 0.9)
    love.graphics.rectangle("fill", handleX, self.y - 5, self.handleWidth, self.height + 10)

    -- Draw label and current value
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.label .. ": " .. string.format("%.2f", self.value), self.x, self.y - 20)
end

function Slider:mousepressed(mx, my, button)
    -- Check if the mouse is over the handle or slider bar
    if button == 1 and mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height then
        self.dragging = true
        self:updateValueFromMouse(mx)
    end
end

function Slider:mousereleased(mx, my, button)
    -- Stop dragging on mouse release
    if button == 1 then
        self.dragging = false
    end
end

function Slider:mousemoved(mx, my, dx, dy)
    -- Update the slider value if dragging
    if self.dragging then
        self:updateValueFromMouse(mx)
    end
end

function Slider:updateValueFromMouse(mx)
    -- Convert mouse x-position to slider value within the defined min/max range
    local normalizedX = (mx - self.x) / self.width
    normalizedX = math.max(0, math.min(1, normalizedX))  -- Clamp between 0 and 1
    self.value = self.min + normalizedX * (self.max - self.min)

    -- Call the callback to apply the new value
    self.callback(self.value)
end

return Slider
