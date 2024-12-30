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
    ui:mousepressed(x, y, button)
    engine:mousepressed(x, y, button)
end

-- Handle mouse release
function love.mousereleased(x, y, button, istouch, presses)
    engine:mousereleased(x, y, button)
end

function love.draw()
    engine:draw()
    ui:draw()
end

-- Key press to reset the game
function love.keypressed(key)
    engine:keypressed(key)
end

function love.quit()
    discordRPC.shutdown()
end
