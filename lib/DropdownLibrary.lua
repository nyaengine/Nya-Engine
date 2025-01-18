-- Dropdown Library
DropdownLibrary = {}
DropdownLibrary.__index = DropdownLibrary

-- Creates a new dropdown menu with options
function DropdownLibrary:new(x, y, width, height, label, options, onSelect)
    local dropdown = setmetatable({}, DropdownLibrary)
    dropdown.x = x
    dropdown.y = y
    dropdown.width = width
    dropdown.height = height
    dropdown.label = label
    dropdown.options = options
    dropdown.selectedOption = options[1]
    dropdown.isOpen = false
    dropdown.onSelect = onSelect
    return dropdown
end

-- Draws the dropdown button and options (if open)
function DropdownLibrary:draw()
    -- Draw the dropdown button
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.label .. ": " .. self.selectedOption, self.x + 5, self.y + 5)

    -- If the dropdown is open, draw the options
    if self.isOpen then
        local optionHeight = 30
        love.graphics.setColor(0.8, 0.8, 0.8)
        for i, option in ipairs(self.options) do
            love.graphics.rectangle("fill", self.x, self.y + i * optionHeight, self.width, optionHeight)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(option, self.x + 5, self.y + i * optionHeight + 5)
        end
    end
end

-- Handles mouse press events to open/close and select an option
function DropdownLibrary:mousepressed(x, y, button)
    if button == 1 then -- Left click
        -- Check if the dropdown button is clicked
        if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
            self.isOpen = not self.isOpen
        end

        -- If the dropdown is open, check if any option is clicked
        if self.isOpen then
            local optionHeight = 30
            for i, option in ipairs(self.options) do
                local optionY = self.y + i * optionHeight
                if x >= self.x and x <= self.x + self.width and y >= optionY and y <= optionY + optionHeight then
                    self.selectedOption = option
                    self.isOpen = false
                    if self.onSelect then
                        self.onSelect(option) -- Call the onSelect callback if provided
                    end
                    break
                end
            end
        end
    end
end

return DropdownLibrary