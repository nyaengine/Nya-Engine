-- this way a cock and ball torture

local fileDialog = {}

-- Dialog state
local isDialogOpen = false
local currentPath = "project"
local files = {}
local selectedFile = nil

-- UI dimensions
local dialogWidth = 400
local dialogHeight = 300
local margin = 10
local rowHeight = 20

-- Extension filter (nil = show all files)
local extensionFilter = nil

local onFileSelected = nil

local function getExtension(filename)
    return filename:match("^.+%.(.+)$")
end

local function passesFilter(filename)
    if not extensionFilter then
        return true
    end

    local ext = getExtension(filename)
    return ext and extensionFilter[ext:lower()] or false
end

function fileDialog.setFilter(extList)
    extensionFilter = {}
    for _, ext in ipairs(extList) do
        extensionFilter[ext:lower()] = true
    end
end

function fileDialog.clearFilter()
    extensionFilter = nil
end

function fileDialog.setCallback(fn)
    onFileSelected = fn
end

local function loadDirectory(path)
    files = {}

    for _, item in ipairs(love.filesystem.getDirectoryItems(path)) do
        local fullPath = path .. "/" .. item
        local info = love.filesystem.getInfo(fullPath)

        if info then
            if info.type == "directory" then
                -- Always show directories
                table.insert(files, {
                    name = item,
                    path = fullPath,
                    isDir = true
                })
            else
                -- Only show files that pass filter
                if passesFilter(item) then
                    table.insert(files, {
                        name = item,
                        path = fullPath,
                        isDir = false,
                        ext = getExtension(item)
                    })
                end
            end
        end
    end
end

function fileDialog.open(startPath)
    isDialogOpen = true
    selectedFile = nil
    currentPath = startPath or currentPath
    loadDirectory(currentPath)
end

function fileDialog.close()
    isDialogOpen = false
    selectedFile = nil
end

function fileDialog.draw()
    if not isDialogOpen then return end

    local sw, sh = love.graphics.getDimensions()
    local dx = (sw - dialogWidth) / 2
    local dy = (sh - dialogHeight) / 2

    -- Background
    love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    love.graphics.rectangle("fill", dx, dy, dialogWidth, dialogHeight)

    -- File list
    local x = dx + margin
    local y = dy + margin

    for _, file in ipairs(files) do
        if file == selectedFile then
            love.graphics.setColor(0.3, 0.6, 1)
            love.graphics.rectangle("fill", x - 5, y - 2, dialogWidth - margin * 2, rowHeight)
            love.graphics.setColor(1, 1, 1)
        end

        if file.isDir then
            love.graphics.setColor(preferences.getColor("label", "textColor"))
            love.graphics.print("[DIR] " .. file.name, x, y)
        else
            love.graphics.setColor(preferences.getColor("label", "textColor"))
            love.graphics.print(file.name, x, y)
        end

        y = y + rowHeight
    end

    -- Buttons
    local by = dy + dialogHeight - 40

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", x, by, 80, 30)
    love.graphics.rectangle("fill", x + 100, by, 80, 30)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Cancel", x + 10, by + 7)
    love.graphics.print("Open", x + 115, by + 7)
end

function fileDialog.mousepressed(mx, my, button)
    if not isDialogOpen or button ~= 1 then return end

    local sw, sh = love.graphics.getDimensions()
    local dx = (sw - dialogWidth) / 2
    local dy = (sh - dialogHeight) / 2

    -- Cancel
    if mx >= dx + margin and mx <= dx + margin + 80 and
       my >= dy + dialogHeight - 40 and my <= dy + dialogHeight - 10 then
        fileDialog.close()
        return
    end

    -- Open
    if mx >= dx + margin + 100 and mx <= dx + margin + 180 and
       my >= dy + dialogHeight - 40 and my <= dy + dialogHeight - 10 then
        if selectedFile then
            if selectedFile.isDir then
                currentPath = selectedFile.path
                loadDirectory(currentPath)
                selectedFile = nil
           else
                if onFileSelected then
                    onFileSelected(selectedFile.path)
                end
                fileDialog.close()
            end
        end
        return
    end

    -- File selection
    local y = dy + margin
    for _, file in ipairs(files) do
        if mx >= dx + margin and mx <= dx + dialogWidth - margin and
           my >= y and my <= y + rowHeight then
            selectedFile = file
            return
        end
        y = y + rowHeight
    end
end

return fileDialog
