local ui = {}
local engine = require("engine")
local ButtonLibrary = require("lib/ButtonLibrary")
local Label = require("lib/label")
local TextBox = require("lib/textbox")
local slider = require("lib/slider")
local window = require("window")
local ide = require("ide")
local CheckboxLib = require("lib/checkbox")
local CheckboxGroup = CheckboxLib.CheckboxGroup

local group

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

local closeButton = ButtonLibrary:new(100, 100, 30, 30, "X", function()
    settingsVis = not settingsVis
end)

local createObjectButton = ButtonLibrary:new(500, 150, 120, 40, "Create Object", function()
    engine:createnewobject()
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

    sceneManager:addScene(sceneName, newScene)
    
    sceneManager:switchTo(sceneName)
    
    table.insert(SceneList, sceneName)
end)

local createscenesButton = ButtonLibrary:new(125, 150, 30, 30, "+", function()
    openScenesWindow()
end)

local createuiButton = ButtonLibrary:new(125, 225, 30, 30, "+", function()
    openUIWindow()
end)

function ui:load()
	 group = CheckboxLib.Checkbox.new(love.graphics.getWidth() - 135, 125, 20, "Collisions")
    group:setOnToggle(function(checked)
        engine:setcollisionobj()
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

    myWindow = window:new(100, 100, 300, 200)
    myWindow:addElement(closeButton)
    myWindow:addElement(ComingSoon)
    myWindow:addElement(EngineSetText)

    createWindow = window:new(500, 100, 300, 300)
    createWindow:addElement(createObjectButton)

    createsceneWindow = window:new(500, 100, 300, 300)
    createsceneWindow:addElement(createSceneButton)

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

function ui:update(dt)
	-- Update all buttons
    local mouseX, mouseY = love.mouse.getPosition()

    for _, button in ipairs(topbarButtons) do
        button:update(mouseX, mouseY)
    end

    for _, button in ipairs(tabButtons) do
        button:update(mouseX, mouseY)
    end

    myWindow:update(dt)
    createWindow:update(dt)
    createsceneWindow:update(dt)

    closeButton:update(mouseX, mouseY)
    createObjectButton:update(mouseX, mouseY)
    createSceneButton:update(mouseX, mouseY)
    createuiButton:update(mouseX, mouseY)
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

function ui:changetext(label, text)
	label:setText(text)
end

function ui:mousepressed(x, y, button, istouch, presses)
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

        closeButton:mousepressed(x, y, button)
        createObjectButton:mousepressed(x, y, button)
        createuiButton:mousepressed(x, y, button)
        createSceneButton:mousepressed(x, y, button)
    end
end

return ui