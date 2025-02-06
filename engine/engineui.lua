local engineui = {}

--engine ui only libraries
local something = require("lib/something")

--UI objects
local group
local projectName
local disX, disY
local disSizeX, disSizeY
local FontDropdown
local ThemeDropdown

local scrollOffset = 0
local scrollSpeed = 20 -- Speed of scrolling

function loadLocalization(language)
    local filePath = "locales/" .. language .. ".json"
    local fileContent = love.filesystem.read(filePath)
    if fileContent then
        local success, data = pcall(dkjson.decode, fileContent)
        if success then
            return data
        else
            error("Failed to parse JSON: " .. data)
        end
    else
        error("Failed to load localization file: " .. filePath)
    end
end

local currentLanguage = "en" -- Default language
local localizationData = loadLocalization(currentLanguage)

-- Buttons
local topbarButtons = {}
local sidebarButtons = {}
local tabButtons = {}
ObjectList = {}
CharacterObjList = {}
SceneList = {}
AudioList = {}

--UI Visibility
ideTest = false

--Labels
local SidebarLabels = {}
local propertiesLabels = {}

--Textboxes
local ObjectTextboxes = {}

-- Windows
local settingsVis = false
local createWin = false
local sceneWin = false
local UIWin = false
local projectWin = true -- set to false when testing the engine

local SidebarUI = UIManager:new()

local closeButton = ButtonLibrary:new(100, 100, 30, 30, "X", function()
    settingsVis = not settingsVis
end)

local createObjectButton = ButtonLibrary:new(500, 150, 120, 40, "Create Object", function()
    -- Only handle object creation logic here
    local newObject = GameObject:new({
        x = 150,
        y = 100,
        width = 50,
        height = 50,
        icon = nil,
        name = "Object " .. tostring(#ObjectList + 1),
        isCollidable = false,
        texture = nil,
        character = false,
    })
    table.insert(objects, newObject)
    table.insert(ObjectList, newObject.name)
end)

local createCharacterObjectButton = ButtonLibrary:new(500, 200, 250, 40, "Create Character Object", function()
    -- Only handle object creation logic here
    local newObject = GameObject:new({
        x = 150,
        y = 100,
        width = 50,
        height = 50,
        icon = nil,
        name = "Char Object " .. tostring(#CharacterObjList + 1),
        isCollidable = false,
        texture = nil,
        character = true,
    })
    table.insert(objects, newObject)
    table.insert(ObjectList, newObject.name)
    table.insert(CharacterObjList, newObject)
end)

local createSceneButton = ButtonLibrary:new(500, 200, 120, 40, "Create Scene", function()
    -- Only handle scene creation logic here
    local sceneName = "Scene " .. tostring(#SceneList + 1)
    
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
    sceneManager:changeScene(sceneName)
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

local createAudioButton = ButtonLibrary:new(125, 300, 30, 30, "+", function()

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

local saveProjectButton = ButtonLibrary:new(200, 10, 120, 30, "Save", function()
    if projectName and projectName ~= "" then
        local projectPath = "project/" .. projectName
        local projectFile = projectPath .. "/project.json"

        -- Prepare project data
        local projectData = {
            objects = {},
            scenes = SceneList,
            CharacterObjList = {}
        }

        -- Capture object data
        for _, obj in ipairs(objects) do
            table.insert(projectData.objects, {
                x = obj.x,
                y = obj.y,
                width = obj.width,
                height = obj.height,
                name = obj.name,
                isCollidable = obj.isCollidable,
                texture = obj.texture,
                character = obj.character
            })
        end

        -- Encode project data to JSON
        local projectJSON = dkjson.encode(projectData, { indent = true })

        -- Write the JSON to the file
        local success, message = love.filesystem.write(projectFile, projectJSON)
        if success then
            print("Project saved successfully!")
        else
            print("Failed to save project: " .. message)
        end
    else
        print("Project name is empty. Save failed.")
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
                -- Clear existing objects
                objects = {}
                ObjectList = {}
                CharacterObjList = {}

                -- Load objects from the project data
                for _, obj in ipairs(projectData.objects or {}) do
                    local newObject = GameObject:new(obj)
                    table.insert(objects, newObject)
                    table.insert(ObjectList, newObject.name)
                    if obj.character == true then
                        table.insert(CharacterObjList, newObject)
                    end
                end

                -- Load scenes
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
    FontDropdown = DropdownLibrary:new(50, 50, 100, 25, {"Poppins", "Noto Sans"})
    LangDropdown = DropdownLibrary:new(50, 50, 100, 25, {"English", "Polish"})
    ThemeDropdown = DropdownLibrary:new(50, 50, 100, 25, {"Nya Mode", "Dark Mode"})

    -- Add callback for language dropdown
    LangDropdown.onSelect = function(selectedLanguage)
        if selectedLanguage == "English" then
            currentLanguage = "en"
        elseif selectedLanguage == "Polish" then
            currentLanguage = "pl"
        end
        updateUIText(currentLanguage)
    end

    if not InEngine then
        projectWin = false
    end
    
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

    AudiosText = Label:new({
        x = 0,
        y = 150,
        text = "Audios",
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

    EngineSetText = Label:new({
        x = 150,
        y = 100,
        text = "Engine Settings",
        color = {1,1,1,1},
        textScale = 1.25
    })

    PositionPropText = Label:new({
        x = love.graphics.getWidth() - 150,
        y = 175,
        text = "Position: ",
        color = {1,1,1,1},
        textScale = 1.25
    })

    SizePropText = Label:new({
        x = love.graphics.getWidth() - 150,
        y = 225,
        text = "Size: ",
        color = {1,1,1,1},
        textScale = 1.25
    })

    TextureFileText = Label:new({
        x = love.graphics.getWidth() - 150,
        y = 275,
        text = "Texture: ",
        color = {1,1,1,1},
        textScale = 1.25
    })

    pajac = something:new({
        x = 0,
        y = 0,
        width = love.graphics:getWidth(),
        height = 100,
        bgClr = customization.getColor("primary")
    })

    wtf = something:new({
        x = love.graphics:getWidth() - 200, 
        y = 100,
        width = 200,
        height = love.graphics:getHeight() - 50, 
        bgClr = customization.getColor("primary")
    })

    versionText = Label:new({
        x = 0,
        y = 0,
        text = "Ver: " .. engineVer,
        color = {1,1,1,1},
        textScale = 1.25
    })

    ProjectName = TextBox.new(0, 100, 125, 30, "Project Name")

    positionTextbox = TextBox.new(love.graphics:getWidth() - 70, 175, 70, 30, "x, y")
    objectImgTB = TextBox.new(love.graphics:getWidth() - 150, 275, 125, 30, "")
    sizeTextbox = TextBox.new(love.graphics:getWidth() - 150, 225, 100, 30, "x, y")
    ObjectNameTextbox = TextBox.new(love.graphics:getWidth() - 150, 325, 100, 30, "ObjectName")
    objectGravityTB = TextBox.new(love.graphics:getWidth() - 150, 325, 100, 30, "50")

    myWindow = window:new(50, 50, love.graphics:getWidth() - 100, love.graphics:getWidth() - 100)
    myWindow:addElement(closeButton)
    myWindow:addElement(EngineSetText)
    myWindow:addElement(FontDropdown)
    myWindow:addElement(ThemeDropdown)
    myWindow:addElement(LangDropdown)

    SidebarUI:addElement(ObjectName)
    SidebarUI:addElement(PositionPropText)
    SidebarUI:addElement(group)
    SidebarUI:addElement(positionTextbox)
    SidebarUI:addElement(objectImgTB)
    SidebarUI:addElement(sizeTextbox)
    SidebarUI:addElement(SizePropText)
    SidebarUI:addElement(TextureFileText)
    SidebarUI:addElement(objectGravityTB)

    createWindow = window:new(500, 100, 300, 300)
    createWindow:addElement(createObjectButton)
    createWindow:addElement(createCharacterObjectButton)

    createsceneWindow = window:new(500, 100, 300, 300)
    createsceneWindow:addElement(createSceneButton)

    projectWindow = window:new(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), {0,0,0}, {0.5,0.5,0.5})
    projectWindow:addElement(ProjectName)
    projectWindow:addElement(createProjectButton)
    projectWindow:addElement(openProjectButton)
    projectWindow:addElement(pajac)
    projectWindow:addElement(versionText)
    projectWindow:addElement(wtf)

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

    local scaleModeButton = ButtonLibrary:new(350, 10, 30, 30, "", function()
        scaling = not scaling
    end, "assets/resize.png")
    
    -- Add buttons to the buttons table
    table.insert(topbarButtons, createRunButton)
    table.insert(topbarButtons, settingsButton)
    table.insert(topbarButtons, saveProjectButton)
    table.insert(topbarButtons, scaleModeButton)
    table.insert(topbarButtons, OpenIDE)
    table.insert(SidebarLabels, SidebarTitle)
    table.insert(SidebarLabels, myLabel)
    table.insert(tabButtons, createButton)
    table.insert(tabButtons, createscenesButton)
    table.insert(tabButtons, createuiButton)
    table.insert(tabButtons, createAudioButton)
    table.insert(propertiesLabels, ObjectName)
    table.insert(propertiesLabels, PositionPropText)
    table.insert(propertiesLabels, SizePropText)
    table.insert(ObjectTextboxes, positionTextbox)
    table.insert(ObjectTextboxes, objectImgTB)
    table.insert(ObjectTextboxes, sizeTextbox)
    table.insert(ObjectTextboxes, objectGravityTB)
    table.insert(propertiesLabels, TextureFileText)
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

    for _, textboxes in ipairs(ObjectTextboxes) do
        textboxes:update(dt)
    end
    
    projectWindow:setSize(love.graphics:getWidth(), love.graphics:getHeight())

    closeButton:update(mouseX, mouseY)
    createObjectButton:update(mouseX, mouseY)
    createCharacterObjectButton:update(mouseX, mouseY)
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
end

function engineui:resize(w, h)
    -- Update the dimensions and positions of the something objects
    pajac:setSize(w, 100)  -- pajac should span the entire width of the screen
    wtf:setSize(200, h - 100)  -- wtf should span the height of the screen minus 50 pixels
    wtf:setPosition(w - 200, 100)  -- wtf should be positioned at the right edge of the screen

    -- Update other UI elements as needed
    projectWindow:setSize(w, h)
    myWindow:setSize(w - 100, h - 100)
    closeButton:setPosition(myWindow.x, myWindow.y)
    EngineSetText:setPosition(myWindow.x * 10, myWindow.y)
    FontDropdown:setPosition(myWindow.x + 20, myWindow.y + 50)
    ThemeDropdown:setPosition(myWindow.x + 20, myWindow.y + 150)
    LangDropdown:setPosition(myWindow.x + 20, myWindow.y + 250)
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

            -- Handle clicks on ObjectList labels
            local objectListStartY = 100 - scrollOffset
            for i, objName in ipairs(ObjectList) do
                local labelX, labelY = 10, objectListStartY + (i - 1) * 20
                local labelWidth, labelHeight = 120, 20 -- Adjust based on font size
                if x >= labelX and x <= labelX + labelWidth and y >= labelY and y <= labelY + labelHeight then
                    selectedObject = objects[i]
                    ObjectName:setText(objName)
                    return
                end
            end

            if settingsVis == true then
                FontDropdown:update(x, y, button)
                LangDropdown:update(x, y, button)
                ThemeDropdown:update(x, y, button)
                closeButton:mousepressed(x, y, button)
            else
                group:mousepressed(x, y, button)

            for _, textboxes in ipairs(ObjectTextboxes) do
                textboxes:mousepressed(x, y, button)
            end

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

            if createWin == true then
            createObjectButton:mousepressed(x, y, button)
            createCharacterObjectButton:mousepressed(x, y, button)
            end
            createuiButton:mousepressed(x, y, button)
            if sceneWin == true then
            createSceneButton:mousepressed(x, y, button)
            end

            if projectWin == true then
            ProjectName:mousepressed(x, y, button)
            createProjectButton:mousepressed(x, y, button)
            openProjectButton:mousepressed(x, y, button)
            end

            for index, obj in ipairs(objects) do
            if obj:isClicked(camX, camY) then
                ObjectName:setText(ObjectList[index])
                return
                end
            end

            -- Reset the ObjectName label if no object is selected
            ObjectName:setText("ObjectName")
            end
        else
            ide.mousepressed(x, y, button)
        end
    end
end

function engineui:draw()
    if ideTest == false and InEngine then
    -- Sidebar
    love.graphics.setColor(customization.getColor("primary"))
    love.graphics.rectangle("fill", windowWidth - 150, 50, 150, windowHeight - 50)
    myLabel:draw()
    myLabel:setPosition(windowWidth - 150, 50)

    -- Explorer Sidebar
    love.graphics.setColor(customization.getColor("primary"))
    love.graphics.rectangle("fill", 0, 50, 150, windowHeight - 50)

    local objectListStartY = 100 - scrollOffset -- Starting Y position for ObjectList

    -- Objects Label
    ObjectsText:setPosition(0, objectListStartY - 30)
    ObjectsText:draw()
    createButton:setPosition(125, objectListStartY - 30)
    SidebarTitle:setPosition(0, objectListStartY - 50)

    -- Draw ObjectList items
    for i, objName in ipairs(ObjectList) do
        local labelX, labelY = 10, objectListStartY + (i - 1) * 20
        local labelWidth, labelHeight = 120, 20 -- Adjust based on font size

        -- Highlight selected label
        if objects[i] == selectedObject then
            love.graphics.setColor(0.8, 0.8, 0.8, 1) -- Light gray background for selection
            love.graphics.rectangle("fill", labelX, labelY, labelWidth, labelHeight)
        end

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(objName, labelX, labelY)
    end

    -- Adjust ScenesText position dynamically based on ObjectList size
    local scenesTextY = objectListStartY + #ObjectList * 20 + 10 -- Add some padding
    ScenesText:setPosition(0, scenesTextY)
    createscenesButton:setPosition(125, scenesTextY)
    ScenesText:draw()

    -- Draw SceneList items
    local sceneListStartY = scenesTextY + 30 -- Start rendering SceneList just below ScenesText
    for i, sceneName in ipairs(SceneList) do
        love.graphics.setColor(1, 1, 1, 1) -- White text
        love.graphics.print(sceneName, 10, sceneListStartY + (i - 1) * 20)
    end

    local uiTextY = sceneListStartY + #SceneList * 20 + 10 -- Add some padding
    UISText:setPosition(0, uiTextY)
    UISText:draw()
    createuiButton:setPosition(125, uiTextY)

    local AudioTextY = sceneListStartY + #SceneList * 20 + 45 -- Add some padding
    AudiosText:setPosition(0, AudioTextY)
    AudiosText:draw()
    createAudioButton:setPosition(125, AudioTextY)

    -- Topbar
    love.graphics.setColor(customization.getColor("topbar"))
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
            SidebarUI:draw()
            for _, lbl in ipairs(propertiesLabels) do
                lbl:setPosition(windowWidth - 150, lbl.y)
            end
            group:setPosition(windowWidth - 135, 125)
            positionTextbox:setPosition(love.graphics:getWidth() - 70, 175)
            positionTextbox.text = selectedObject.x .. ", " .. selectedObject.y
            objectImgTB:setPosition(love.graphics:getWidth() - 70, 275)
            sizeTextbox:setPosition(love.graphics:getWidth() - 100, 225)
            sizeTextbox.text = selectedObject.width .. ", " .. selectedObject.height
            objectGravityTB:setPosition(love.graphics:getWidth() - 150, objectGravityTB.y)
            v.gravity = objectGravityTB.text
        end
    end

    if settingsVis == true then
        myWindow:draw()
        myWindow:setSize(love.graphics:getWidth() - 100, love.graphics:getHeight() - 100)
        closeButton:setPosition(myWindow.x, myWindow.y)
        EngineSetText:setPosition(myWindow.x * 10, myWindow.y)
        FontDropdown:setPosition(myWindow.x + 20, myWindow.y + 50)
        ThemeDropdown:setPosition(myWindow.x + 20, myWindow.y + 150)
        LangDropdown:setPosition(myWindow.x + 20, myWindow.y + 250)
        
        if FontDropdown.selected == "Poppins" then 
            selectedFont = "Poppins"
        elseif FontDropdown.selected == "Noto Sans" then
            selectedFont = "Noto Sans"
        end

        -- Update language when dropdown selection changes
    if LangDropdown.selected == "English" and currentLanguage ~= "en" then
        currentLanguage = "en"
        updateUIText(currentLanguage)
    elseif LangDropdown.selected == "Polish" and currentLanguage ~= "pl" then
        currentLanguage = "pl"
        updateUIText(currentLanguage)
    end
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
        projectWindow.fill = customization.getColor("background")
        projectWindow:draw()
    end

    elseif ideTest == true and InEngine then
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
        elseif filename:match("%.glsl$") then
            local filePath = scriptsFolder .. "/" .. filename
            local scriptContent = love.filesystem.read(filePath)
            if scriptContent then
                local chunk, err = load(scriptContent, filename, "t", _G)
                love.graphics.newShader(scriptContent)
            else
                print("Error loading shaders " .. filename .. ":" .. err)
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
        for _, textboxes in ipairs(ObjectTextboxes) do
            textboxes:textinput(text)
        end
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
    local filePath = scriptsFolder .. "/" .. scriptName

    -- Write the code to the file
    local success, message = love.filesystem.write(filePath, code)

    -- Check if the file was successfully saved
    if success then
        print("Code successfully saved to " .. filePath)
    else
        print("Failed to save code: " .. message)
    end
end

function updateUIText(language)
    currentLanguage = language
    localizationData = loadLocalization(language)

    -- Update button texts
    createObjectButton:setText(localizationData.createObject)
    createCharacterObjectButton:setText(localizationData.createCharacterObject)
    createSceneButton:setText(localizationData.createScene)

    -- Update label texts
    SidebarTitle:setText(localizationData.explorer)
    myLabel:setText(localizationData.properties)
    ObjectsText:setText(localizationData.objects)
    ScenesText:setText(localizationData.scenes)
    UISText:setText(localizationData.ui)
    AudiosText:setText(localizationData.audios)
    EngineSetText:setText(localizationData.enginesettings)
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