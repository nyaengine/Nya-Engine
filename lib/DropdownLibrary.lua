local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(x, y, width, height, options, font)
    local self = setmetatable({}, Dropdown)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.options = options
    self.selected = options[1]
    self.isOpen = false
    self.font = font or love.graphics.newFont(14)
    self.optionHeight = self.font:getHeight() + 4
    return self
end

function Dropdown:toggle()
    self.isOpen = not self.isOpen
end

function Dropdown:selectOption(index)
    self.selected = self.options[index]
    self.isOpen = false
end

function Dropdown:draw()
    -- Draw the selected option
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.selected, self.x + 5, self.y + (self.height - self.font:getHeight()) / 2)

    -- Draw the dropdown arrow
    love.graphics.line(self.x + self.width - 15, self.y + self.height / 2, self.x + self.width - 5, self.y + self.height / 2)

    -- Draw the options if the dropdown is open
    if self.isOpen then
        for i, option in ipairs(self.options) do
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", self.x, self.y + self.height + (i - 1) * self.optionHeight, self.width, self.optionHeight)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(option, self.x + 5, self.y + self.height + (i - 1) * self.optionHeight + (self.optionHeight - self.font:getHeight()) / 2)
        end
    end
end

function Dropdown:update(mx, my, mousePressed)
    if mousePressed then
        -- Check if the dropdown area was clicked
        if mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height then
            self:toggle()
        end
        
        if self.isOpen then
            -- Check if an option was clicked
            for i, option in ipairs(self.options) do
                local optionY = self.y + self.height + (i - 1) * self.optionHeight
                if mx >= self.x and mx <= self.x + self.width and my >= optionY and my <= optionY + self.optionHeight then
                    self:selectOption(i)
                    break
                end
            end
        end
    end
end

return Dropdown
