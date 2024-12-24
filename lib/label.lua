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
        color = {1, 1, 1, 1} -- White
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

    return instance
end

-- Draw the label on the screen
function Label:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)
    love.graphics.print(self.text, self.x, self.y)
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

return Label
