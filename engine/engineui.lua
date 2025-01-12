local engineui = {}

local UI = require("UI")

--UI objects
local group
local projectName
local disX, disY
local disSizeX, disSizeY

local scrollOffset = 0
local scrollSpeed = 20 -- Speed of scrolling

-- Buttons
local topbarButtons = {}
local sidebarButtons = {}
local tabButtons = {}
ObjectList = {}
SceneList = {}

--UI Visibility
ideTest = false

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
    -- Only handle object creation logic here
    local newObject = ObjectLibrary:new(150, 100, 50, 50)
    table.insert(objects, newObject)
    table.insert(ObjectList, "Object " .. tostring(#objects))
end)

local createSceneButton = ButtonLibrary:new(500, 200, 120, 40, "Create Scene", function()
    -- Only handle scene creation logic here
    local sceneName = "Scene " .. tostring(#sceneManager.scenes + 1)
    
    local newScene = {
        name = sceneName,
        enter = function(self)
            print(self.name .. " has been entered.")
        end,
        exit = function(self)
            print(self.name .. " has been exited.")
        end,
        update = function(self, dt)
            -- Scene-specific update logic
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

local createButton = ButtonLibrary:new(125, 70, 30, 30, "+", function()
        openCreateWindow()
end)

local createProjectButton = ButtonLibrary:new(0, 150, 125, 30, "Create Project", function()
    projectName = ProjectName.text
    if projectName and projectName ~= "" then
        local projectPath = "project/" .. projectName
        love.filesystem.createDirectory(projectPath)

        local projectFile = projectPath .. "/project.json"
        local projectData = {
            objects = {},
            scenes = {},
        }

        -- Encode project data to JSON
        local projectJSON = dkjson.encode(projectData, { indent = true })

        -- Write the JSON to the file
        local success, message = love.filesystem.write(projectFile, projectJSON)
        if success then
            projectWin = false
        else
            print("Failed to create project file: " .. message)
        end
    else
        print("Project name is empty.")
    end
end)

local openProjectButton = ButtonLibrary:new(150, 150, 125, 30, "Open Project", function()
    projectName = ProjectName.text
    if projectName and projectName ~= "" then
        local projectPath = "project/" .. projectName
        local projectFile = projectPath .. "/project.json"

        if love.filesystem.getInfo(projectFile) then
            local projectJSON = love.filesystem.read(projectFile)
            local projectData, _, err = dkjson.decode(projectJSON)

            if projectData then
                objects = projectData.objects or {}
                SceneList = projectData.scenes or {}
                projectWin = false
            else
                print("Failed to load project data:", err)
            end
        else
            print("Project file does not exist.")
        end
    else
        print("Project name is empty.")
    end
end)

function engineui:load()
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
        textScale = 1.25,
        background = true,
        bgx = 120,
        bgy = 25
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

    ProjectName = TextBox.new(0, 100, 125, 30, "Project Name")

    positionTextbox = TextBox.new(love.graphics:getWidth() - 150, 175, 125, 30, "150, 100")

    myWindow = window:new(100, 100, 300, 200)
    myWindow:addElement(closeButton)
    myWindow:addElement(ComingSoon)
    myWindow:addElement(EngineSetText)

    createWindow = window:new(500, 100, 300, 300)
    createWindow:addElement(createObjectButton)

    createsceneWindow = window:new(500, 100, 300, 300)
    createsceneWindow:addElement(createSceneButton)

    projectWindow = window:new(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), {0,0,0}, {0.5,0.5,0.5})
    projectWindow:addElement(ProjectName)
    projectWindow:addElement(createProjectButton)
    projectWindow:addElement(openProjectButton)

    local createRunButton = ButtonLibrary:new(love.graphics.getWidth() / 2, 10, 120, 30, "Run", function()
        running = not running
        if running then
        loadAndRunScripts()
        end
    end)

    local settingsButton = ButtonLibrary:new(10, 10, 30, 30, "", function()
        openSettingsWindow()
    end, "assets/settings.png")

    local OpenIDE = ButtonLibrary:new(50, 10, 100, 30, "IDE", function()
        openIDE()
    end)

    local saveProjectButton = ButtonLibrary:new(200, 10, 120, 30, "Save", function()
        
    end)

    -- Add buttons to the buttons table
    table.insert(topbarButtons, createRunButton)
    table.insert(topbarButtons, settingsButton)
    table.insert(topbarButtons, saveProjectButton)
    table.insert(topbarButtons, OpenIDE)
    table.insert(SidebarLabels, SidebarTitle)
    table.insert(SidebarLabels, myLabel)
    table.insert(tabButtons, createButton)
    table.insert(tabButtons, createscenesButton)
    table.insert(tabButtons, createuiButton)
    table.insert(propertiesLabels, ObjectName)
    table.insert(propertiesLabels, SizePropText)
end

function engineui:update(dt)
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
    projectWindow:update(dt)

    positionTextbox:update(dt)
    
    projectWindow:setSize(love.graphics:getWidth(), love.graphics:getHeight())

    closeButton:update(mouseX, mouseY)
    createObjectButton:update(mouseX, mouseY)
    createSceneButton:update(mouseX, mouseY)
    createuiButton:update(mouseX, mouseY)
    createProjectButton:update(mouseX, mouseY)
    openProjectButton:update(mouseX, mouseY)

    if ideTest == true then
        ide.update(dt)
    end

    if UIWin == true then
        UI:update(dt)
    end
end

function openCreateWindow()
    createWin = not createWin
end

function openScenesWindow()
    sceneWin = not sceneWin
end

function openUIWindow()
    UIWin = not UIWin
    UI:load()
end

function openIDE()
    if projectWin == false then
        ide.load()
        ideTest = true
    end
end

function engineui:mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        if ideTest == false then
            group:mousepressed(x, y, button)

            positionTextbox:mousepressed(x, y, button)

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
            ProjectName:mousepressed(x, y, button)
            createProjectButton:mousepressed(x, y, button)
            openProjectButton:mousepressed(x, y, button)

            for index, obj in ipairs(objects) do
            if obj:isClicked(camX, camY) then
                ObjectName:setText(ObjectList[index])
                return
                end
            end

            -- Reset the ObjectName label if no object is selected
            ObjectName:setText("ObjectName")
        else
            ide.mousepressed(x, y, button)
        end
    end
end

function engineui:draw()
    if ideTest == false then
        -- Sidebar
    love.graphics.setColor(1, 0.4, 0.7)
    love.graphics.rectangle("fill", windowWidth - 150, 50, 150, windowHeight - 50)
    myLabel:setPosition(windowWidth - 150, 50)

    -- Explorer Sidebar
    love.graphics.setColor(1, 0.4, 0.7)
    love.graphics.rectangle("fill", 0, 50, 150, windowHeight - 50)

    local objectListStartY = 100 - scrollOffset -- Starting Y position for ObjectList

    -- Objects Label
    ObjectsText:setPosition(0, objectListStartY - 25)
    ObjectsText:draw()
    createButton:setPosition(125, objectListStartY - 25)
    SidebarTitle:setPosition(0, objectListStartY - 50)

    -- Draw ObjectList items
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

            positionTextbox:draw()
            positionTextbox:setPosition(love.graphics:getWidth() - 150, 175)
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

    if UIWin == true then
        UI:draw()
    end

    if projectWin == true then
        projectWindow:draw()
    end
    else
        ide:draw()
    end
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

function openSettingsWindow()
    settingsVis = not settingsVis
end

function engineui:textinput(text)
    if ideTest == true then
        ide.textinput(text)
    end

    if projectWin == true then
        ProjectName:textinput(text)
    end

    if projectWin == false and ideTest == false then
        positionTextbox:textinput(text)
    end
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

function engineui:wheelmoved(x, y)
    if x ~= 0 or y ~= 0 then
        scrollOffset = scrollOffset - y * scrollSpeed
        -- Clamp the scroll offset to ensure it doesn't scroll too far
        scrollOffset = math.max(0, scrollOffset)
    end
end

function engineui:keypressed(key)
    if ideTest == true then
        ide.keypressed(key)
    end
end

return engineui