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
local ide = require("ide")
local CheckboxGroup = CheckboxLib.CheckboxGroup

local assetsFolder = love.filesystem.createDirectory("project")

local font = love.graphics.newFont("assets/fonts/Poppins-Regular.ttf", 15)

-- Game objects
local objects = {}
local CollisionObjects = {}
local selectedObject = nil
local running = false
local isDragging = false
local sceneManager = SceneManager:new()
local camera = Camera:new(0, 0, 1)
local group

local engineVer = "1.0"

local discordRPC = require 'lib/discordRPC'
local appId = require 'applicationId'

-- Buttons
local topbarButtons = {}
local sidebarButtons = {}
local tabButtons = {}
local ObjectList = {}
local SceneList = {}

--Labels
local SidebarLabels = {}
local propertiesLabels = {}

-- Windows
local settingsVis = false
local createWin = false
local sceneWin = false
local UIWin = false
local projectWin = true -- set to false when testing the engine

local closeButton = ButtonLibrary:new(100, 100, 30, 30, "X", function()
    settingsVis = not settingsVis
end)

local createObjectButton = ButtonLibrary:new(500, 150, 120, 40, "Create Object", function()
    local newObject = ObjectLibrary:new(150, 100, 50, 50)
    table.insert(objects, newObject)
    table.insert(ObjectList, "Object " .. tostring(#objects)) -- Add only the new object to ObjectList
end)

local createSceneButton = ButtonLibrary:new(500, 150, 120, 40, "Create Scene", function()
    -- Create a unique name for the new scene
    local sceneName = "Scene " .. tostring(#sceneManager.scenes + 1)
    
    -- Define the new scene with basic functionality
    local newScene = {
        name = sceneName,
        enter = function(self)
            print(self.name .. " has been entered.")
        end,
        exit = function(self)
            print(self.name .. " has been exited.")
        end,
        update = function(self, dt)
            -- Scene-specific update logic here
        end,
        draw = function(self)
            love.graphics.print("You are in " .. self.name, 400, 300)
        end,
    }

    -- Add the new scene to the SceneManager
    sceneManager:addScene(sceneName, newScene)
    
    -- Automatically switch to the new scene
    sceneManager:switchTo(sceneName)
    
    -- Add the scene name to the ObjectList for display
    table.insert(SceneList, sceneName)
end)

local createscenesButton = ButtonLibrary:new(125, 150, 30, 30, "+", function()
    openScenesWindow()
end)

local createuiButton = ButtonLibrary:new(125, 225, 30, 30, "+", function()
    openUIWindow()
end)

-- Initialize the game
function love.load()
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    group = CheckboxLib.Checkbox.new(love.graphics.getWidth() - 135, 125, 20, "Collisions")
    group:setOnToggle(function(checked)
        table.insert(CollisionObjects, selectedObject)
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

    UISText = Label:new({
        x = 0,
        y = 225,
        text = "UI",
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

    SizePropText = Label:new({
        x = love.graphics.getWidth() - 150,
        y = 175,
        text = "Size: ",
        color = {1,1,1,1},
        textScale = 1.25
    })

    SomeText = Label:new({
        x = 0,
        y = 0,
        text = "Name your project: ",
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

    createsceneWindow = window:new(500, 100, 300, 300)
    createsceneWindow:addElement(createSceneButton)

    projectWindow = window:new(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), {0,0,0}, {0.5,0.5,0.5})
    projectWindow:addElement(SomeText)

    -- Create the "Create Object" button

    local createButton = ButtonLibrary:new(125, 70, 30, 30, "+", function()
        openCreateWindow()
    end)

    local createRunButton = ButtonLibrary:new(love.graphics.getWidth() / 2, 10, 120, 40, "Run", function()
        running = not running
    end)

    local settingsButton = ButtonLibrary:new(10, 10, 30, 30, "", function()
        openSettingsWindow()
    end, "assets/settings.png")

    discordRPC.initialize(appId, true)

    -- Add buttons to the buttons table
    table.insert(topbarButtons, createRunButton)
    table.insert(topbarButtons, settingsButton)
    table.insert(SidebarLabels, SidebarTitle)
    table.insert(SidebarLabels, myLabel)
    table.insert(tabButtons, createButton)
    table.insert(tabButtons, createscenesButton)
    table.insert(tabButtons, createuiButton)
    table.insert(propertiesLabels, ObjectName)
    table.insert(propertiesLabels, SizePropText)
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
    createsceneWindow:update(dt)
    projectWindow:update(dt)
    projectWindow:setSize(love.graphics:getWidth(), love.graphics:getHeight())

    closeButton:update(mouseX, mouseY)
    createObjectButton:update(mouseX, mouseY)
    createSceneButton:update(mouseX, mouseY)
    createuiButton:update(mouseX, mouseY)

    sceneManager:update(dt)

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

function openScenesWindow()
    sceneWin = not sceneWin
end

function openUIWindow()
    UIWin = not UIWin
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        group:mousepressed(x, y, button)

        -- Check if the click is within the properties sidebar
        local sidebarX = love.graphics.getWidth() - 150
        local sidebarY = 50
        local sidebarWidth = 150
        local sidebarHeight = love.graphics.getHeight() - 50

        if x >= sidebarX and x <= sidebarX + sidebarWidth and y >= sidebarY and y <= sidebarY + sidebarHeight then
            -- Click is within the sidebar, do not deselect
            return
        end

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
        for index, obj in ipairs(objects) do
            if obj:isClicked(camX, camY) then
                selectedObject = obj
                isDragging = true
                
                -- Update ObjectName label with the corresponding name from ObjectList
                ObjectName:setText(ObjectList[index])
                return
            end
        end

        closeButton:mousepressed(x, y, button)
        createObjectButton:mousepressed(x, y, button)
        createuiButton:mousepressed(x, y, button)
        createSceneButton:mousepressed(x, y, button)

        -- Deselect if clicked outside any object
        selectedObject = nil
        -- Reset the ObjectName label if no object is selected
        ObjectName:setText("ObjectName")
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
    local objectListStartY = 100 -- Starting Y position for ObjectList
    for i, objName in ipairs(ObjectList) do
        love.graphics.setColor(1, 1, 1, 1) -- White text
        love.graphics.print(objName, 10, objectListStartY + (i - 1) * 20)
    end

    -- Adjust ScenesText position dynamically based on ObjectList size
    local scenesTextY = objectListStartY + #ObjectList * 20 + 10 -- Add some padding
    ScenesText:setPosition(0, scenesTextY)
    createscenesButton:setPosition(125, scenesTextY)
    ScenesText:draw()

    -- Draw SceneList items
    local sceneListStartY = scenesTextY + 25 -- Start rendering SceneList just below ScenesText
    for i, sceneName in ipairs(SceneList) do
        love.graphics.setColor(1, 1, 1, 1) -- White text
        love.graphics.print(sceneName, 10, sceneListStartY + (i - 1) * 20)
    end

    local uiTextY = sceneListStartY + #SceneList * 20 + 10 -- Add some padding
    UISText:setPosition(0, uiTextY)
    UISText:draw()
    createuiButton:setPosition(125, uiTextY)

    sceneManager:draw()

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
            for _, lbl in ipairs(propertiesLabels) do
                lbl:draw()
                lbl:setPosition(windowWidth - 150, lbl.y)
            end
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

    if sceneWin == true then
        createsceneWindow:draw()
    end

    if projectWin == true then
        projectWindow:draw()
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
