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
CheckboxGroup = CheckboxLib.CheckboxGroup

local engineUI = require("engine/engineui")
local engine = require("engine/engine")

local assetsFolder = love.filesystem.createDirectory("project")

local font = love.graphics.newFont("assets/fonts/Poppins-Regular.ttf", 15)

local engineVer = "1.0"
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

function loadAndRunScripts()
    local scriptsFolder = "project/" .. projectName .. "/scripts"
    local files = love.filesystem.getDirectoryItems(scriptsFolder)

    for _, filename in ipairs(files) do
        if filename:match("%.lua$") then -- Ensure only Lua files are loaded
            local filePath = scriptsFolder .. "/" .. filename
            local scriptContent = love.filesystem.read(filePath)

            if scriptContent then
                local chunk, err = load(scriptContent, filename, "t", _G)
                if chunk then
                    local success, runtimeErr = pcall(chunk)
                    if not success then
                        print("Error running script " .. filename .. ": " .. runtimeErr)
                    end
                else
                    print("Error loading script " .. filename .. ": " .. err)
                end
            end
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

function saveIDECode(code)
    -- Define the path to the scripts folder within the project directory
    local scriptsFolder = "project/" .. projectName .. "/scripts"

    -- Check if the "scripts" folder exists
    local info = love.filesystem.getInfo(scriptsFolder)

    -- If the "scripts" folder doesn't exist, create it
    if not info then
        love.filesystem.createDirectory(scriptsFolder)
    end

    -- Use the script name from the textbox
    local scriptName = scriptNameTextBox.text
    if scriptName == "" then
        scriptName = "unnamed_script" -- Default name if empty
    end
    local filePath = scriptsFolder .. "/" .. scriptName .. ".lua"

    -- Write the code to the file
    local success, message = love.filesystem.write(filePath, code)

    -- Check if the file was successfully saved
    if success then
        print("Code successfully saved to " .. filePath)
    else
        print("Failed to save code: " .. message)
    end
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
    elseif key == "return" and positionTextbox:isFocused() then
        selectedObject.x = positionTextbox.text
        positionTextbox.focused = false
    end

    if ideTest == true then
        ide.keypressed(key)
    end
end

function love.wheelmoved(x, y)
    engineUI:wheelmoved(x,y)
end

function love.quit()
    discordRPC.shutdown()
end
