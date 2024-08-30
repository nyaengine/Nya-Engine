-- main.lua

local Engine = require("engine.engine")
local UIManager = require("engine.ui.ui_manager")
local UICreator = require("ui_creator")

local uiCreator

function love.load()
    Engine:init()
    uiCreator = UICreator:new()
end

function love.update(dt)
    Engine:update(dt)
    uiCreator:update(dt)
end

function love.draw()
    Engine:draw()
    uiCreator:draw()
end

function love.mousepressed(x, y, button)
    uiCreator:mousepressed(x, y, button)
end

function love.textinput(text)
    UIManager:textinput(text)  -- Handles text input for text boxes
end

function love.keypressed(key)
    UIManager:keypressed(key)  -- Handles key presses for UI elements
end
