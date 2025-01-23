Frame = {}
Frame.__index = Frame

-- Create a new frame
function Frame.new(x, y, width, height, isScrollable, direction)
    return setmetatable({
        x = x,
        y = y,
        width = width,
        height = height,
        isScrollable = isScrollable or false,  -- If the frame is scrollable
        direction = direction or "vertical",  -- 'vertical' or 'horizontal'
        elements = {},  -- Store elements inside the frame
        scrollOffset = 0  -- Scroll position (only for vertical scroll)
    }, Frame)
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

return Frame