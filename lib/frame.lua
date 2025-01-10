Frame = {}
Frame.__index = Frame

-- Create a new frame
function Frame.new(x, y, width, height, isScrollable, direction)
    local self = setmetatable({}, Frame)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.isScrollable = isScrollable or false  -- If the frame is scrollable
    self.direction = direction or "vertical"  -- 'vertical' or 'horizontal'
    self.elements = {}  -- Store elements inside the frame
    self.scrollOffset = 0  -- Scroll position (only for vertical scroll)
    return self
end

-- Add an element to the frame
function Frame:addElement(element)
    table.insert(self.elements, element)
end

-- Draw the frame and its elements
function Frame:draw()
    -- Draw background for the frame
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw the elements in the frame
    love.graphics.setColor(1, 1, 1, 1)

    local totalWidth = 0
    local totalHeight = 0
    for _, element in ipairs(self.elements) do
        if self.direction == "vertical" then
            totalHeight = totalHeight + element.height
        else
            totalWidth = totalWidth + element.width
        end
    end

    local currentPosX = self.x
    local currentPosY = self.y

    if self.direction == "vertical" then
        if self.isScrollable then
            love.graphics.setScissor(self.x, self.y, self.width, self.height)
        end

        for _, element in ipairs(self.elements) do
            element:draw(currentPosX, currentPosY)
            currentPosY = currentPosY + element.height
        end
    else
        for _, element in ipairs(self.elements) do
            element:draw(currentPosX, currentPosY)
            currentPosX = currentPosX + element.width
        end
    end

    if self.isScrollable then
        love.graphics.setScissor()
    end
end

-- Update the scroll position based on user input (for vertical scroll)
function Frame:update(dt)
    if self.isScrollable then
        if love.mouse.isDown(1) then
            local mouseY = love.mouse.getY()

            -- Scroll based on mouse position
            if mouseY > self.y and mouseY < self.y + self.height then
                self.scrollOffset = self.scrollOffset + (love.mouse.getY() - self.y - self.scrollOffset)
            end
        end
    end
end

-- UI Element class
UIElement = {}
UIElement.__index = UIElement

-- Create a new UI element (e.g., Button, Label, etc.)
function UIElement.new(x, y, width, height, label)
    local self = setmetatable({}, UIElement)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.label = label or ""
    return self
end

-- Draw the UI element (e.g., button, text)
function UIElement:draw(x, y)
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.rectangle("fill", x, y, self.width, self.height)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(self.label, x + 10, y + 10)
end

-- Example usage
local myFrame
local button1, button2, label1

function love.load()
    -- Create a frame that is scrollable and has vertical orientation
    myFrame = Frame.new(100, 100, 300, 200, true, "vertical")
    
    -- Create some buttons and labels
    button1 = UIElement.new(0, 0, 100, 30, "Button 1")
    button2 = UIElement.new(0, 0, 100, 30, "Button 2")
    label1 = UIElement.new(0, 0, 100, 30, "Label 1")
    
    -- Add elements to the frame
    myFrame:addElement(button1)
    myFrame:addElement(button2)
    myFrame:addElement(label1)
end

function love.update(dt)
    -- Update the frame's scroll position
    myFrame:update(dt)
end

function love.draw()
    -- Draw the frame
    myFrame:draw()
end
