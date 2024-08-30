-- main.lua

local Engine = require("engine.engine")
local UIManager = require("engine.ui.ui_manager")

function love.load()
    Engine:init()

    -- Create a button and a label
    UIManager:addButton({
        x = 300, y = 300, width = 100, height = 50, label = "Click Me!",
        onClick = function() print("Button Clicked!") end
    })

    UIManager:addLabel({
        x = 300, y = 250, text = "Hello, Game World!"
    })

    -- Create a text box
    UIManager:addTextBox({
        x = 300, y = 200, width = 200, height = 30, placeholder = "Type here..."
    })
end

function love.update(dt)
    Engine:update(dt)
    UIManager:update(dt)
end

function love.draw()
    Engine:draw()
    UIManager:draw()
end

function love.mousepressed(x, y, button)
    UIManager:mousepressed(x, y, button)
end

function love.textinput(text)
    UIManager:textinput(text)
end

function love.keypressed(key)
    UIManager:keypressed(key)
end
