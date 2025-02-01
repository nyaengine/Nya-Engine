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
customization = require("customization")
love3d = require("lib/3d_library")

local engineUI = require("engine/engineui")
local engine = require("engine/engine")

local assetsFolder = love.filesystem.createDirectory("project")

selectedFont = "Poppins"
font = customization.getFont(selectedFont)

engineVer = "Prototype"
inEngine = true

--local discordRPC = require 'lib/discordRPC' --temporary removed due to there being no Linux support
--local appId = require 'applicationId'

-- Initialize the game
function love.load()
    love.graphics.setFont(font)

    love.graphics.setDefaultFilter("linear", "linear")

    --nextPresenceUpdate = 0
    
    --discordRPC.initialize(appId, true)

    engineUI:load()
end

-- Update the game
function love.update(dt)
    --[[if nextPresenceUpdate < love.timer.getTime() then
        discordRPC.updatePresence(discordApplyPresence())
        nextPresenceUpdate = love.timer.getTime() + 2.0
    end

    discordRPC.runCallbacks()]]

    engine:update(dt)
    engineUI:update(dt)
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

    engine:mousepressed(x, y, button)
    engineUI:mousepressed(x, y, button)
end

-- Handle mouse release
function love.mousereleased(x, y, button, istouch, presses)
    engine:mousereleased(x, y, button)
end

function love.draw()
    engine:draw()
    engineUI:draw()
end

function love.textinput(text)
    engineUI:textinput(text)
end

-- Key press to reset the game
function love.keypressed(key)
    engine:keypressed(key)
    engineUI:keypressed(key)

    if key == "escape" then
        love.event.quit()
    end
end

function love.wheelmoved(x, y)
    engineUI:wheelmoved(x,y)
end

function love.quit()
    --discordRPC.shutdown()
end
