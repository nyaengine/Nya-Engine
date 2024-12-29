--this script creates overlaying windows. 
local window = {}
window.__index = window

function window:new(x, y, width, height)
    local self = setmetatable({}, window)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.elements = {} -- Table to hold child elements
    return self
end

-- Method to add an element to the window
function window:addElement(element)
    table.insert(self.elements, element)
end

-- Update method for the window and its elements
function window:update(dt)
    for _, element in ipairs(self.elements) do
        if element.update then
            element:update(dt)
        end
    end
end

-- Draw method for the window and its elements
function window:draw()
    love.graphics.setColor(1, 0.4, 0.7)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0.6, 0.1, 0.3)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw each element inside the window
    for _, element in ipairs(self.elements) do
        if element.draw then
            element:draw()
        end
    end
end

return window
