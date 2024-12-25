local Slider = {}
Slider.__index = Slider

function Slider.new(x, y, width, height, min, max, value)
    local self = setmetatable({}, Slider)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.min = min
    self.max = max
    self.value = value or min
    self.isDragging = false
    self.thumbWidth = 20
    self.thumbX = self.x + (self.value - self.min) / (self.max - self.min) * (self.width - self.thumbWidth)
    return self
end

function Slider:update(dt)
    if self.isDragging then
        local mouseX = love.mouse.getX()
        self.thumbX = math.max(self.x, math.min(mouseX - self.thumbWidth / 2, self.x + self.width - self.thumbWidth))
        self.value = self.min + (self.thumbX - self.x) / (self.width - self.thumbWidth) * (self.max - self.min)
    end
end

function Slider:draw()
    -- Draw the slider track
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", self.x, self.y + self.height / 2 - 5, self.width, 10)

    -- Draw the slider thumb
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.thumbX, self.y, self.thumbWidth, self.height)

    -- Draw the value as text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("%.2f", self.value), self.x + self.width + 10, self.y + self.height / 2 - 10)
end

function Slider:mousepressed(x, y, button)
    if button == 1 then
        if x >= self.thumbX and x <= self.thumbX + self.thumbWidth and y >= self.y and y <= self.y + self.height then
            self.isDragging = true
        end
    end
end

function Slider:mousereleased(x, y, button)
    if button == 1 then
        self.isDragging = false
    end
end

return Slider
