-- Required files
preferences = require("preferences")

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
GameObject = require("lib/GameObject")
UIManager = require("lib/UIManager")
SVG = require("lib/svg_images")
videoLibrary = require("lib/videoLib")
ParallaxBackground = require("lib/parallaxbackground")
Sprite = require("lib/sprite")
modding_api = require("api/modding_api")
UI = require("UI")

_G.modding_api = modding_api  -- Make the modding API globally accessible

selectedFont = "Poppins"

local mods = {}

local assetsFolder = love.filesystem.createDirectory("project")
local svgMeshes = {}

objects = {}
audios = {}
CollisionObjects = {}
font = preferences.getFont(selectedFont)

engineVer = "Prototype"
InEngine = true

if InEngine then
    engineUI = require("engine/engineui")
    engine = require("engine/engine")
end

-- Initialize the game
function love.load()
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("linear", "linear")
    svgMeshes = SVG.load("3D.svg")

    if InEngine then
        engineUI:load()
    end
end

-- Update the game
function love.update(dt)

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

    SVG.draw(svgMeshes)
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
    saveSettings()
    return false
end

function loadMods()
    local modDir = "mods/"
    local files = love.filesystem.getDirectoryItems(modDir)

    for _, file in ipairs(files) do
        if love.filesystem.getInfo(modDir .. file, "directory") then
            local modPath = modDir .. file .. "/mod.lua"
            if love.filesystem.getInfo(modPath) then
                local modCode = love.filesystem.read(modPath)
                if modCode then
                    local chunk, err = load(modCode, file, "t", _G)
                    if chunk then
                        local success, mod = pcall(chunk)
                        if success and type(mod) == "table" and mod.init then
                            mod.init() -- Call the mod's initialization function
                            table.insert(mods, mod)
                            print("Loaded mod:", file)
                        else
                            print("Failed to initialize mod:", file)
                        end
                    else
                        print("Error loading mod:", err)
                    end
                end
            else
                print("No mod.lua found in mod folder:", file)
            end
        end
    end
end