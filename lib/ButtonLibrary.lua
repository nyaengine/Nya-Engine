local ButtonLibrary = {}
ButtonLibrary.__index = ButtonLibrary

-- Create a new button
function ButtonLibrary:new(x, y, width, height, label, onClick, imagePath)
    local btn = {}
    setmetatable(btn, ButtonLibrary)

    btn.x = x or 0
    btn.y = y or 0
    btn.width = width or 100
    btn.height = height or 40
    btn.label = label or "Button"
    btn.onClick = onClick or function() end
    btn.isHovered = false
    btn.background = true
    btn.transparencyBG = 1

    -- Load the image if the path is provided
    btn.image = nil
    if imagePath then
        btn.image = love.graphics.newImage(imagePath)
    end

    return btn
end

-- Update button hover state based on mouse position
function ButtonLibrary:update(mouseX, mouseY)
    if not (mouseX and mouseY and self.x and self.y and self.width and self.height) then
        return
    end

    self.isHovered = mouseX >= self.x and mouseX <= self.x + self.width and
                     mouseY >= self.y and mouseY <= self.y + self.height
end

function ButtonLibrary:SetTransparency(val)
    self.transparencyBG = val
end

function ButtonLibrary:setText(text)
    self.label = text
end

function ButtonLibrary:IsVisibleBG(vis)
    self.background = vis
end

-- Check if the button is clicked
function ButtonLibrary:mousepressed(mouseX, mouseY, button)
    if button == 1 and self.isHovered then
        self.onClick() -- Trigger the button's onClick function
    end
end

function ButtonLibrary:setPosition(x, y)
    self.x = x 
    self.y = y
end

-- Draw the button
function ButtonLibrary:draw()
    -- Button background
    if self.background then
        if self.isHovered then
            love.graphics.setColor(customization.getColor("secondary"), self.transparencyBG) -- Hover color
        else
            love.graphics.setColor(customization.getColor("primary"), self.transparencyBG) -- Default color
        end
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        -- Button border
        love.graphics.setColor(0, 0, 0, self.transparencyBG)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end

    -- Draw the image if it exists
    if self.image then
        local imgWidth, imgHeight = self.image:getDimensions()
        local scaleX = self.width / imgWidth
        local scaleY = self.height / imgHeight

        love.graphics.setColor(1, 1, 1) -- Reset color for image
        love.graphics.draw(self.image, self.x, self.y, 0, scaleX, scaleY)
    end

    -- Button label
    if self.label then
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.label, self.x, self.y + self.height / 4, self.width, "center")
    end
end

return ButtonLibrary
