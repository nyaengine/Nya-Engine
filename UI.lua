-- This is the window for building the UI
local UI = {}

-- Correctly import the Frame module
local Frame = require("lib/frame") -- Ensure this module exists and is correct

local UIList = {}
local frames = {}

-- Button for creating new frames
local frameCreateBut = ButtonLibrary:new(0, 50, 100, 30, "Frame", function()
    local newFrame = Frame.new(50, 50, 250, 250, false) -- Use Frame.new correctly
    table.insert(frames, newFrame)
    table.insert(UIList, "Frame " .. tostring(#frames))
end)

-- Main frame instance
local mainFrame -- Declare mainFrame in the correct scope

function UI:load()
    -- Create a new frame instance
    mainFrame = Frame.new(50, 50, 250, 250, false) -- Initialize the main frame
end

function UI:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Sidebar
    love.graphics.setColor(1, 0.4, 0.7)
    love.graphics.rectangle("fill", 0, 50, 150, windowHeight - 50)

    -- Topbar
    love.graphics.setColor(1, 0.4, 0.7, 0.5)
    love.graphics.rectangle("fill", 0, 0, windowWidth, 50)

    -- Draw the main frame
    if mainFrame then
        mainFrame:draw()
    end
end

function UI:update(dt)
    -- Update the main frame
    if mainFrame then
        mainFrame:update(dt)
    end
end

return UI
