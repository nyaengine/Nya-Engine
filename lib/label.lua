--[[ 
Label Library for LÖVE2D

Usage:

1. Include this library in your project.
2. Create a label using Label:new().
3. Call label:draw() inside love.draw().

Example:

local Label = require 'label'

function love.load()
    myLabel = Label:new({
        x = 100,
        y = 50,
        text = "Hello, World!",
        font = love.graphics.newFont(20),
        color = {1, 1, 1, 1}, -- White
        textScale = 1.5 -- Scale the text by 1.5 times
    })
end

function love.draw()
    myLabel:draw()
end
]]--

local Label = {}
Label.__index = Label

-- Constructor function
function Label:new(options)
    local instance = setmetatable({}, Label)

    instance.x = options.x or 0
    instance.y = options.y or 0
    instance.text = options.text or "Label"
    instance.font = options.font or love.graphics.getFont() -- Default font
    instance.color = options.color or {1, 1, 1, 1} -- Default to white color
    instance.textScale = options.textScale or 1 -- Default to no scaling
    instance.background = options.background or false
    instance.bgx = options.bgx or 0
    instance.bgy = options.bgy or 0

    return instance
end

-- Draw the label on the screen
function Label:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)

    -- Apply scaling to the label's position and text
    love.graphics.push()  -- Save the current transformation state
    love.graphics.translate(self.x, self.y)  -- Move to the label's position
    love.graphics.scale(self.textScale)  -- Apply the scaling factor

    if self.background == true then
        love.graphics.setColor(customization.getColor("secondary"))
        love.graphics.rectangle("fill", 0, 0, self.bgx, self.bgy)
        love.graphics.setColor(1, 1, 1, 1) -- Reset to default color
    end

    -- Draw the text at the origin (0, 0) after transformation
    love.graphics.print(self.text, 0, 0)
    
    love.graphics.pop()  -- Restore the transformation state

    love.graphics.setColor(1, 1, 1, 1) -- Reset to default color
end

-- Update the label's text
function Label:setText(newText)
    self.text = newText
end

-- Update the label's position
function Label:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Update the label's font
function Label:setFont(newFont)
    self.font = newFont
end

-- Update the label's color
function Label:setColor(r, g, b, a)
    self.color = {r, g, b, a or 1}
end

-- Update the label's text scale
function Label:setTextScale(scale)
    self.textScale = scale
end

return Label
