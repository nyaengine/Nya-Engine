-- Required files
local ObjectLibrary = require("lib/ObjectLibrary")
local ButtonLibrary = require("lib/ButtonLibrary")
local window = require("window")
local Camera = require("lib/Camera")
local Label = require("lib/label")
local SceneManager = require("lib/SceneManager")
local AudioEngine = require("lib/AudioEngine")
local TextBox = require("lib/textbox")
local slider = require("lib/slider")
local CheckboxLib = require("lib/checkbox")
local CheckboxGroup = CheckboxLib.CheckboxGroup

local assetsFolder = love.filesystem.createDirectory("project")

local font = love.graphics.newFont("assets/fonts/Poppins-Regular.ttf", 15)

-- Game objects
local objects = {}
local CollisionObjects = {}
local selectedObject = nil
local running = false
local isDragging = false
local camera = Camera:new(0, 0, 1)
local group

local discordRPC = require 'lib/discordRPC'
local appId = require 'applicationId'

-- Buttons
local topbarButtons = {}
local sidebarButtons = {}
local tabButtons = {}
local ObjectList = {}

--Labels
local SidebarLabels = {}
local propertiesLabels = {}

-- Windows
local settingsVis = false
local createWin = false

local closeButton = ButtonLibrary:new(100, 100, 30, 30, "X", function()
    settingsVis = not settingsVis
end)

local createObjectButton = ButtonLibrary:new(500, 150, 120, 40, "Create Object", function()
    local newObject = ObjectLibrary:new(150, 100, 50, 50)
    table.insert(objects, newObject)
    table.insert(ObjectList, "Object " .. tostring(#objects)) -- Add only the new object to ObjectList
end)

-- Initialize the game
function love.load()
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    group = CheckboxLib.Checkbox.new(love.graphics.getWidth() - 135, 125, 20, "Collisions")
    group:setOnToggle(function(checked)
        print("Option 1 is now:", checked and "Checked" or "Unchecked")
    end)

    myLabel = Label:new({
        x = love.graphics.getWidth() - 150,
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

    ObjectsText = Label:new({
        x = 0,
        y = 75,
        text = "Objects",
        color = {1,1,1,1},
        textScale = 1.25
    })

    ScenesText = Label:new({
        x = 0,
        y = 150,
        text = "Scenes",
        color = {1,1,1,1},
        textScale = 1.25,
        background = true,
        bgx = 120,
        bgy = 25
    })

    ObjectName = Label:new({
        x = love.graphics.getWidth() - 150,
        y = 75,
        text = "ObjectName",
        color = {1, 1, 1, 1}, -- White
        textScale = 1.25, -- Scale the text by 1.5 times
        background = true,
        bgx = 120,
        bgy = 25
    })

    ComingSoon = Label:new({
        x = 150,
        y = 150,
        text = "Coming Soon",
        color = {1,0,0,1},
        textScale = 1.25
    })

    EngineSetText = Label:new({
        x = 150,
        y = 100,
        text = "Engine Settings",
        color = {1,1,1,1},
        textScale = 1.25
    })

    nextPresenceUpdate = 0
    myWindow = window:new(100, 100, 300, 200)
    myWindow:addElement(closeButton)
    myWindow:addElement(ComingSoon)
    myWindow:addElement(EngineSetText)

    createWindow = window:new(500, 100, 300, 300)
    createWindow:addElement(createObjectButton)

    -- Create the "Create Object" button

    local createButton = ButtonLibrary:new(125, 70, 30, 30, "+", function()
        openCreateWindow()
    end)

    local createRunButton = ButtonLibrary:new(love.graphics.getWidth() / 2, 10, 120, 40, "Run", function()
        running = not running
    end)

    local settingsButton = ButtonLibrary:new(10, 10, 30, 30, "⚙", function()
        openSettingsWindow()
    end)

    discordRPC.initialize(appId, true)

    -- Add buttons to the buttons table
    table.insert(topbarButtons, createRunButton)
    table.insert(topbarButtons, settingsButton)
    table.insert(SidebarLabels, SidebarTitle)
    table.insert(SidebarLabels, myLabel)
    table.insert(tabButtons, createButton)
    table.insert(propertiesLabels, ObjectName)
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

    for _, button in ipairs(topbarButtons) do
        button:update(mouseX, mouseY)
    end

    for _, button in ipairs(tabButtons) do
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
    createWindow:update(dt)

    closeButton:update(mouseX, mouseY)
    createObjectButton:update(mouseX, mouseY)

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

function openCreateWindow()
    createWin = not createWin
end

-- Handle mouse presses
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        -- Check if a button is clicked

        for _, btn in ipairs(topbarButtons) do
            if btn:mousepressed(x, y, button) then
                return
            end
        end

        for _, btn in ipairs(tabButtons) do
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

        closeButton:mousepressed(x, y, button)
        createObjectButton:mousepressed(x, y, button)

        group:mousepressed(x, y, button)

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

function love.draw()
    love.graphics.setBackgroundColor(0.3, 0.3, 0.3)
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
    love.graphics.rectangle("fill", windowWidth - 150, 50, 150, windowHeight - 50)
    myLabel:setPosition(windowWidth - 150, 50)

    -- Explorer Sidebar
    love.graphics.setColor(1, 0.4, 0.7)
    love.graphics.rectangle("fill", 0, 50, 150, windowHeight - 50)

    -- Objects Label
    love.graphics.setColor(0.8, 0.3, 0.6)
    love.graphics.rectangle("fill", 0, 75, 150, 25)
    ObjectsText:draw()

    -- Draw ObjectList items
    local startY = 100 -- Start position for object list
    for i, objName in ipairs(ObjectList) do
        love.graphics.setColor(1, 1, 1, 1) -- White text
        love.graphics.print(objName, 10, startY + (i - 1) * 20)
        ScenesText:setPosition(0, startY + i * 20)
    end

    ScenesText:draw()

    -- Topbar
    love.graphics.setColor(1, 0.4, 0.7, 0.5)
    love.graphics.rectangle("fill", 0, 0, windowWidth, 50)

    -- Draw all buttons
    for _, btn in ipairs(topbarButtons) do
        btn:draw()
    end

    for _, btn in ipairs(tabButtons) do
        btn:draw()
        btn:IsVisibleBG(false)
    end

    for _, lbl in ipairs(SidebarLabels) do
        lbl:draw()
    end

    for _, v in ipairs(objects) do
        if selectedObject == v then
            ObjectName:draw()
            ObjectName:setPosition(windowWidth - 150, 75)
            group:draw()
            group:setPosition(windowWidth - 135, 125)
        end
    end

    if settingsVis == true then
        myWindow:draw()
    end

    if createWin == true then
        createWindow:draw()
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
