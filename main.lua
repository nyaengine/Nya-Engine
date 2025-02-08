-- Required files
ButtonLibrary = require("lib/ButtonLibrary")
window = require("window")
Camera = require("lib/Camera")
Label = require("lib/label")
SceneManager = require("lib/SceneManager")
AudioEngine = require("lib/AudioEngine")
TextBox = require("lib/textbox")
slider = require("lib/slider")
CheckboxLib = require("lib/checkbox")
dkjson = require("lib/dkjson")
ide = require("ide")
frame = require("lib/frame")
fileDialog = require("lib/fileDialog")
CheckboxGroup = CheckboxLib.CheckboxGroup
DropdownLibrary = require("lib/DropdownLibrary")
SaveLoad = require("lib/save_load")
GameObject = require("engine/GameObject")
UIManager = require("engine/UIManager")
love3d = require("lib/3d_library")

selectedTheme = "default"
selectedFont = "Poppins"

preferences = require("preferences")

local assetsFolder = love.filesystem.createDirectory("project")

objects = {}
CollisionObjects = {}
font = preferences.getFont(selectedFont)

engineVer = "Prototype"
InEngine = true

if InEngine then
    engineUI = require("engine/engineui")
    engine = require("engine/engine")
end

--local discordRPC = require 'lib/discordRPC' --temporary removed due to there being no Linux support
--local appId = require 'applicationId'

-- Initialize the game
function love.load()
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("linear", "linear")

    --nextPresenceUpdate = 0
    
    --discordRPC.initialize(appId, true)

    if InEngine then
        engineUI:load()
    end
end

-- Update the game
function love.update(dt)
    --[[if nextPresenceUpdate < love.timer.getTime() then
        discordRPC.updatePresence(discordApplyPresence())
        nextPresenceUpdate = love.timer.getTime() + 2.0
    end

    discordRPC.runCallbacks()]]

    if InEngine then
        engine:update(dt)
        engineUI:update(dt)
    end

    if InEngine == false then
        for _, obj in ipairs(objects) do
            obj:update(dt)
        end
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

function love.mousepressed(x, y, button, istouch, presses)
    sidebarX = love.graphics.getWidth() - 150
    sidebarY = 50
    sidebarWidth = 150
    sidebarHeight = love.graphics.getHeight() - 50

    if InEngine then
    engine:mousepressed(x, y, button)
    engineUI:mousepressed(x, y, button)
end
end

-- Handle mouse release
function love.mousereleased(x, y, button, istouch, presses)
    if InEngine then
    engine:mousereleased(x, y, button)
end
end

function love.draw()
    if InEngine then
    engine:draw()
    engineUI:draw()
end
    
    if InEngine == false then
        for _, obj in ipairs(objects) do
            obj:draw()
        end
    end
end

function love.textinput(text)
    if InEngine then
    engineUI:textinput(text)
end
end

-- Key press to reset the game
function love.keypressed(key)
    if InEngine then
        engine:keypressed(key)
        engineUI:keypressed(key)
    end

    if key == "escape" then
        love.event.quit()
    end
end

function love.wheelmoved(x, y)
    if InEngine then
    engineUI:wheelmoved(x,y)
    ide.wheelmoved(x, y)
end
end

function love.resize(w, h)
    if engineUI and InEngine then
        engineUI:resize(w, h)
    end
end

function love.quit()
    --discordRPC.shutdown()
end
