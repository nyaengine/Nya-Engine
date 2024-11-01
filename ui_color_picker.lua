local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker:new(x, y, callback)
    local cp = setmetatable({}, ColorPicker)
    cp.x = x
    cp.y = y
    cp.callback = callback
    cp.color = {1, 1, 1}  -- Default white
    cp.sliders = {
        {label = "R", value = 1, max = 1},
        {label = "G", value = 1, max = 1},
        {label = "B", value = 1, max = 1},
    }
    return cp
end

function ColorPicker:update(dt)
    -- Placeholder for updating color values if needed
end

function ColorPicker:render()
    for i, slider in ipairs(self.sliders) do
        local y = self.y + (i - 1) * 30
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(slider.label, self.x, y, 30, "center")

        -- Draw slider bar
        love.graphics.setColor(slider.label == "R" and {1, 0.5, 0.5} or slider.label == "G" and {0.5, 1, 0.5} or {0.5, 0.5, 1})
        love.graphics.rectangle("fill", self.x + 40, y, 100 * slider.value, 20)

        love.graphics.setColor(1, 1, 1)
    end
end

function ColorPicker:mousepressed(x, y, button)
    for i, slider in ipairs(self.sliders) do
        local sy = self.y + (i - 1) * 30
        if x > self.x + 40 and x < self.x + 140 and y > sy and y < sy + 20 then
            local new_value = (x - self.x - 40) / 100
            slider.value = new_value
            self.color[i] = new_value
            self.callback(self.color)
        end
    end
end

return ColorPicker
