-- Required files
local ui = require("UI")
local engine = require("engine")

local assetsFolder = love.filesystem.createDirectory("project")

local font = love.graphics.newFont("assets/fonts/Poppins-Regular.ttf", 15)

local engineVer = "1.0"

local discordRPC = require 'lib/discordRPC'
local appId = require 'applicationId'

-- Initialize the game
function love.load()
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    nextPresenceUpdate = 0

    discordRPC.initialize(appId, true)

    ui:load()
    engine:load()
end

-- Update the game
function love.update(dt)

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

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        ui:mousepressed(x, y, button)
        engine:mousepressed(x, y, button)
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
