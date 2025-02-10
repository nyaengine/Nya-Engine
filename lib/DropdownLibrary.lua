local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown:new(x, y, width, height, options)
    local self = setmetatable({}, Dropdown)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.options = options
    self.selected = options[1]
    self.isOpen = false
    self.optionHeight = font:getHeight() + 4
    return self
end

function Dropdown:toggle()
    self.isOpen = not self.isOpen
end

function Dropdown:selectOption(option)
    if type(option) == "number" then
        -- If the option is a number, treat it as an index
        self.selected = self.options[option]
    elseif type(option) == "string" then
        -- If the option is a string, find the corresponding index
        for i, opt in ipairs(self.options) do
            if opt == option then
                self.selected = self.options[i]
                break
            end
        end
    else
        -- Handle invalid input
        error("Invalid option type. Expected number or string, got " .. type(option))
    end
    self.isOpen = false

    -- Call the onSelect callback if it exists
    if self.onSelect then
        self.onSelect(self.selected)
    end
end

function Dropdown:draw()
    -- Draw the selected option
    love.graphics.setColor(preferences.getColor("dropdown", "background"))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(preferences.getColor("dropdown", "textColor"))
    love.graphics.print(self.selected, self.x + 5, self.y + (self.height - font:getHeight()) / 2)

    -- Draw the dropdown arrow
    love.graphics.line(self.x + self.width - 15, self.y + self.height / 2, self.x + self.width - 5, self.y + self.height / 2)

    -- Draw the options if the dropdown is open
    if self.isOpen then
        for i, option in ipairs(self.options) do
            love.graphics.setColor(preferences.getColor("dropdown", "background"))
            love.graphics.rectangle("fill", self.x, self.y + self.height + (i - 1) * self.optionHeight, self.width, self.optionHeight)
            love.graphics.setColor(preferences.getColor("dropdown", "textColor"))
            love.graphics.print(option, self.x + 5, self.y + self.height + (i - 1) * self.optionHeight + (self.optionHeight - font:getHeight()) / 2)
        end
    end
end

function Dropdown:setPosition(x, y)
    self.x = x 
    self.y = y
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
