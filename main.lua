-- Required files
local ObjectLibrary = require("lib/ObjectLibrary")
local ButtonLibrary = require("lib/ButtonLibrary")
local window = require("window")
local Camera = require("lib/Camera")
local Label = require("lib/label")
local SceneManager = require("lib/SceneManager")
local AudioEngine = require("lib/AudioEngine")

local font = love.graphics.newFont("assets/fonts/NotoSans-Regular.ttf", 15)

-- Game objects
local objects = {}
local selectedObject = nil
local running = false
local isDragging = false
local camera = Camera:new(0, 0, 1)

local discordRPC = require 'lib/discordRPC'
local appId = require 'applicationId'

-- Buttons
local buttons = {}
local topbarButtons = {}
local sidebarButtons = {}

--Labels
local SidebarLabels = {}

-- Windows
local settingsVis = false

local closeButton = ButtonLibrary:new(100, 100, 30, 30, "X")

-- Initialize the game
function love.load()
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    myLabel = Label:new({
        x = love.graphics.getWidth() - 200,
        y = 50,
        text = "Properties",
        color = {1, 1, 1, 1}, -- White
        textScale = 1.25 -- Scale the text by 1.5 times
    })

    SidebarTitle = Label:new({
        x = 0,
        y = 50,
        text = "Explorer",
        color = {1, 1, 1, 1},
        textScale = 1.25 -- Scale the text by 1.5 times
    })

    nextPresenceUpdate = 0
    myWindow = window:new(100, 100, 300, 200)
    myWindow:addElement(closeButton)

    -- Create the "Create Object" button
    local createObjectButton = ButtonLibrary:new(10, 70, 120, 40, "Create Object", function()
        local newObject = ObjectLibrary:new(150, 100, 50, 50)
        table.insert(objects, newObject)
    end)

    local createRunButton = ButtonLibrary:new(love.graphics.getWidth() / 2, 10, 120, 40, "Run", function()
        running = not running
    end)

    local settingsButton = ButtonLibrary:new(10, 10, 30, 30, "⚙", function()
        openSettingsWindow()
    end)

    discordRPC.initialize(appId, true)

    -- Add buttons to the buttons table
    table.insert(buttons, createObjectButton)
    table.insert(topbarButtons, createRunButton)
    table.insert(topbarButtons, settingsButton)
    table.insert(SidebarLabels, SidebarTitle)
    table.insert(SidebarLabels, myLabel)
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

    for _, button in ipairs(topbarButtons) do
        button:update(mouseX, mouseY)
    end

    -- Dragging logic
    if isDragging and selectedObject then
        local mouseX, mouseY = love.mouse.getPosition()
        selectedObject.x = mouseX / camera.scale - camera.x - selectedObject.width / 2
        selectedObject.y = mouseY / camera.scale - camera.y - selectedObject.height / 2
    end

    if nextPresenceUpdate < love.timer.getTime() then
        discordRPC.updatePresence(discordApplyPresence())
        nextPresenceUpdate = love.timer.getTime() + 2.0
    end
    discordRPC.runCallbacks()

    myWindow:update(dt)

    if love.keyboard.isDown("w") then
        camera:move(0, -10)
    end

    if love.keyboard.isDown("s") then
        camera:move(0, 10)
    end

    if love.keyboard.isDown("d") then
        camera:move(10, 0)
    end

    if love.keyboard.isDown("a") then
        camera:move(-10, 0)
    end

    if love.keyboard.isDown("=") then
        camera:zoom(1.1)
    end

    if love.keyboard.isDown("-") then
        camera:zoom(0.9)
    end
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

        for _, btn in ipairs(topbarButtons) do
            if btn:mousepressed(x, y, button) then
                return
            end
        end

        -- Check if an object is clicked
        local camX, camY = x / camera.scale + camera.x, y / camera.scale + camera.y
        for _, obj in ipairs(objects) do
            if obj:isClicked(camX, camY) then
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
    love.graphics.setBackgroundColor(0.3,0.3,0.3)
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Apply camera
    camera:apply()

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

    -- Reset camera
    camera:reset()

    -- Sidebar
    love.graphics.setColor(1, 0.4, 0.7)
    love.graphics.rectangle("fill", windowWidth - 200, 50, windowWidth - 150, windowHeight - 50)

    -- Sidebar2
    love.graphics.setColor(1, 0.4, 0.7)
    love.graphics.rectangle("fill", 0, 50, 150, windowHeight - 50)

    -- Topbar
    love.graphics.setColor(1, 0.4, 0.7, 0.5)
    love.graphics.rectangle("fill", 0, 0, windowWidth, 50)

    -- Draw all buttons
    for _, btn in ipairs(buttons) do
        btn:draw()
    end

    for _, btn in ipairs(topbarButtons) do
        btn:draw()
    end

    myLabel:setPosition(love.graphics.getWidth() - 200, 50)
    for _, lbl in ipairs(SidebarLabels) do
        lbl:draw()
    end

    if settingsVis == true then
        myWindow:draw()
    end
end

function openSettingsWindow()
    settingsVis = not settingsVis
end

-- Key press to reset the game
function love.keypressed(key)
    if key == "r" then
        objects = {} -- Clear all objects
        selectedObject = nil
    elseif key == "f5" then
        running = not running
    elseif key == "f" then
        camera:focus(selectedObject)
    end
end

function love.quit()
    discordRPC.shutdown()
end
