-- Required files
ObjectLibrary = require("lib/ObjectLibrary")
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
CheckboxGroup = CheckboxLib.CheckboxGroup
DropdownLibrary = require("lib/DropdownLibrary")

local engineUI = require("engine/engineui")
local engine = require("engine/engine")

local assetsFolder = love.filesystem.createDirectory("project")

local font = love.graphics.newFont("assets/fonts/Poppins-Regular.ttf", 15)

local engineVer = "Prototype"
local inEngine = true

local discordRPC = require 'lib/discordRPC'
local appId = require 'applicationId'

-- Initialize the game
function love.load()
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    nextPresenceUpdate = 0
    
    discordRPC.initialize(appId, true)

    engineUI:load()
end

-- Update the game
function love.update(dt)
    if nextPresenceUpdate < love.timer.getTime() then
        discordRPC.updatePresence(discordApplyPresence())
        nextPresenceUpdate = love.timer.getTime() + 2.0
    end

    discordRPC.runCallbacks()

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
end

function love.wheelmoved(x, y)
    engineUI:wheelmoved(x,y)
end

function love.quit()
    discordRPC.shutdown()
end
