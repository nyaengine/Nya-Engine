-- Checkbox Library for LOVE2D
local Checkbox = {}
Checkbox.__index = Checkbox

-- Create a new checkbox
function Checkbox.new(x, y, size, label)
    return setmetatable({
        x = x,
        y = y,
        size = size or 20,
        label = label or "",
        checked = false,
        font = love.graphics.getFont(),
        onToggle = nil, -- Callback function for toggle
    }, Checkbox)
end

-- Set new position for the checkbox
function Checkbox:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Set the callback function for toggle
function Checkbox:setOnToggle(callback)
    self.onToggle = callback
end

-- Draw the checkbox
function Checkbox:draw()
    -- Draw the box
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)

    -- Fill the box if checked
    if self.checked then
        love.graphics.line(self.x, self.y, self.x + self.size, self.y + self.size)
        love.graphics.line(self.x + self.size, self.y, self.x, self.y + self.size)
    end

    -- Draw the label
    if self.label ~= "" then
        love.graphics.print(self.label, self.x + self.size + 10, self.y + (self.size / 2 - self.font:getHeight() / 2))
    end
end

-- Handle mouse press
function Checkbox:mousepressed(mx, my, button)
    if button == 1 then -- Left mouse button
        if mx >= self.x and mx <= self.x + self.size and my >= self.y and my <= self.y + self.size then
            self.checked = not self.checked
            if self.onToggle then
                self.onToggle(self.checked)
            end
        end
    end
end

-- Library to manage multiple checkboxes
local CheckboxGroup = {}
CheckboxGroup.__index = CheckboxGroup

function CheckboxGroup.new()
    return setmetatable({
        checkboxes = {}
    }, CheckboxGroup)
end

function CheckboxGroup:addCheckbox(x, y, size, label)
    table.insert(self.checkboxes, Checkbox.new(x, y, size, label))
end

function CheckboxGroup:draw()
    for _, checkbox in ipairs(self.checkboxes) do
        checkbox:draw()
    end
end

function CheckboxGroup:mousepressed(mx, my, button)
    for _, checkbox in ipairs(self.checkboxes) do
        checkbox:mousepressed(mx, my, button)
    end
end

-- Return the modules
return {
    Checkbox = Checkbox,
    CheckboxGroup = CheckboxGroup
}
