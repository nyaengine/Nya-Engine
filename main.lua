-- Nya Engine

-- Required files
local ObjectLibrary = require("lib/ObjectLibrary")
local ButtonLibrary = require("lib/ButtonLibrary")

-- Game objects
local objects = {}
local selectedObject = nil
local running = false
local isDragging = false

local discordRPC = require 'lib/discordRPC'
local appId = require 'applicationId'

-- Buttons
local buttons = {}

-- Initialize the game
function love.load()
    nextPresenceUpdate = 0
    -- Create the "Create Object" button
    local createObjectButton = ButtonLibrary:new(10, 10, 120, 40, "Create Object", function()
        local newObject = ObjectLibrary:new(100, 100, 50, 50)
        table.insert(objects, newObject)
    end)

    local createRunButton = ButtonLibrary:new(10, 70, 120, 40, "Run", function()
        running = not running
    end)

    discordRPC.initialize(appId, true)

    -- Add buttons to the buttons table
    table.insert(buttons, createObjectButton)
    table.insert(buttons, createRunButton)
end

-- Update the game
function love.update(dt)
    -- Update all objects
    if running then
        for _, obj in ipairs(objects) do
            obj:update(dt)
        end
    end

    -- Update all buttons
    local mouseX, mouseY = love.mouse.getPosition()
    for _, button in ipairs(buttons) do
        button:update(mouseX, mouseY)
    end

    -- Dragging logic
    if isDragging and selectedObject then
        local mouseX, mouseY = love.mouse.getPosition()
        selectedObject.x = mouseX - selectedObject.width / 2
        selectedObject.y = mouseY - selectedObject.height / 2
    end

    if nextPresenceUpdate < love.timer.getTime() then
      discordRPC.updatePresence(discordApplyPresence())
      nextPresenceUpdate = love.timer.getTime() + 2.0
  end
  discordRPC.runCallbacks()
end

function discordApplyPresence()
    detailsNow = "Developing"
    stateNow = ""
  
  presence = {
    largeImageKey = "nyaengine_icon",
    largeImageText = "Nya Engine 1.0",
    details = detailsNow,
    state = stateNow,
    startTimestamp = now,
  }
  
  return presence
end

-- Handle mouse presses
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        -- Check if a button is clicked
        for _, btn in ipairs(buttons) do
            if btn:mousepressed(x, y, button) then
                return
            end
        end

        -- Check if an object is clicked
        for _, obj in ipairs(objects) do
            if obj:isClicked(x, y) then
                selectedObject = obj
                isDragging = true
                return
            end
        end

        -- Deselect if clicked outside any object
        selectedObject = nil
    end
end

-- Handle mouse release
function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        isDragging = false
    end
end

-- Draw everything
function love.draw()
    -- Draw all buttons
    for _, btn in ipairs(buttons) do
        btn:draw()
    end

    -- Draw all objects
    for _, obj in ipairs(objects) do
        obj:draw()
    end

    -- Highlight the selected object
    if selectedObject then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("line", selectedObject.x, selectedObject.y, selectedObject.width, selectedObject.height)
        love.graphics.setColor(1, 1, 1, 1) -- Reset color
    end
end

-- Key press to reset the game
function love.keypressed(key)
    if key == "r" then
        objects = {} -- Clear all objects
        selectedObject = nil
    elseif key == "space" then
        running = not running
    end
end

function love.quit()
  discordRPC.shutdown()
end