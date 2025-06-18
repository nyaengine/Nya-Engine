local fileDialog = {}

-- Dialog state
local isDialogOpen = false
local currentPath = "project"  -- Set this to your starting folder
local files = {}
local selectedFile = nil

-- UI dimensions
local dialogWidth = 400
local dialogHeight = 300
local margin = 10

-- Supported audio extensions
local audioExtensions = { mp3 = true, wav = true, ogg = true, flac = true }

-- Helper to check if file is audio
local function isAudioFile(filename)
    local ext = filename:match("^.+%.(.+)$")
    return ext and audioExtensions[ext:lower()]
end

-- Load directory contents
function loadDirectory(path)
    local items = love.filesystem.getDirectoryItems(path)
    files = {}
    for _, item in ipairs(items) do
        local fullPath = path .. "/" .. item
        local info = love.filesystem.getInfo(fullPath)
        table.insert(files, {
            name = item,
            isDir = info and info.type == "directory",
            path = fullPath,
            isAudio = not (info and info.type == "directory") and isAudioFile(item)
        })
    end
end

-- Open the dialog
function fileDialog.open()
    isDialogOpen = true
    loadDirectory(currentPath)
end

-- Close the dialog
function fileDialog.close()
    isDialogOpen = false
    selectedFile = nil
end

-- Draw the dialog
function fileDialog.draw()
    if not isDialogOpen then return end

    -- Draw dialog background
    local screenWidth, screenHeight = love.graphics.getDimensions()
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", (screenWidth - dialogWidth) / 2, (screenHeight - dialogHeight) / 2, dialogWidth, dialogHeight)

    -- Draw file list
    love.graphics.setColor(1, 1, 1)
    local x = (screenWidth - dialogWidth) / 2 + margin
    local y = (screenHeight - dialogHeight) / 2 + margin
    for i, file in ipairs(files) do
        if file == selectedFile then
            love.graphics.setColor(0.3, 0.6, 1)
            love.graphics.rectangle("fill", x - margin / 2, y - 5, dialogWidth - 2 * margin, 20)
            love.graphics.setColor(1, 1, 1)
        end
        if file.isDir then
            love.graphics.print("[DIR] " .. file.name, x, y)
        elseif file.isAudio then
            love.graphics.setColor(0.2, 1, 0.2)
            love.graphics.print("[AUDIO] " .. file.name, x, y)
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.print(file.name, x, y)
        end
        y = y + 20
    end

    -- Draw buttons
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", x, screenHeight / 2 + dialogHeight / 2 - 40, 80, 30)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Cancel", x + 10, screenHeight / 2 + dialogHeight / 2 - 35)

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", x + 100, screenHeight / 2 + dialogHeight / 2 - 40, 80, 30)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Open", x + 110, screenHeight / 2 + dialogHeight / 2 - 35)
end

-- Mouse interaction
function fileDialog.mousepressed(x, y, button)
    if not isDialogOpen or button ~= 1 then return end

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local dialogX = (screenWidth - dialogWidth) / 2
    local dialogY = (screenHeight - dialogHeight) / 2

    -- Check if Cancel button is clicked
    if x >= dialogX + margin and x <= dialogX + margin + 80 and
       y >= screenHeight / 2 + dialogHeight / 2 - 40 and y <= screenHeight / 2 + dialogHeight / 2 - 10 then
        fileDialog.close()
        return
    end

    -- Check if Open button is clicked
    if x >= dialogX + margin + 100 and x <= dialogX + margin + 180 and
       y >= screenHeight / 2 + dialogHeight / 2 - 40 and y <= screenHeight / 2 + dialogHeight / 2 - 10 then
        if selectedFile then
            if selectedFile.isDir then
                -- Navigate into the directory
                currentPath = selectedFile.path
                loadDirectory(currentPath)
                selectedFile = nil
            elseif selectedFile.isAudio then
                -- Play the audio file
                local success, source = pcall(function()
                    return love.audio.newSource(selectedFile.path, "static")
                end)
                if success and source then
                    source:play()
                else
                    print("Failed to play audio: " .. selectedFile.path)
                end
                fileDialog.close()
            else
                -- Load the file content and update the IDE
                local fileContent = love.filesystem.read(selectedFile.path)
                if fileContent then
                    require("ide").updateTextEditorContent(fileContent)
                    require("ide").updateCursorPosition()
                else
                    print("Failed to load the file: " .. selectedFile.path)
                end
                fileDialog.close()
            end
        else
            print("No file selected!")
        end
        return
    end

    -- Check if a file is selected
    local fileX = dialogX + margin
    local fileY = dialogY + margin
    for _, file in ipairs(files) do
        if x >= fileX and x <= fileX + dialogWidth - 2 * margin and y >= fileY and y <= fileY + 20 then
            selectedFile = file
            print("Selected file: " .. file.name)
            return
        end
        fileY = fileY + 20
    end
end

return fileDialog
