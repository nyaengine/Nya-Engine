local ide = {}

local font = love.graphics.newFont("assets/fonts/JetbrainsMono/JetBrainsMono-Regular.ttf")

local syntax  -- Will hold the parsed syntax data

scriptName = "unnamed_script.lua"

scriptNameInput = {
    x = 0,
    y = 60,
    width = 150,
    height = 30,
    text = "unnamed_script",
    isActive = false
}

scriptNameTextBox = TextBox.new(0, 60, 150, 30, "Script Name", preferences.getColor("textbox", "background"), preferences.getColor("textbox", "textColor"))

-- Editor states
local textEditorContent = ""
local cursorPos = {x = 180, y = 50} -- Track the cursor position
local selectedText = ""  -- Hold the selected text
local cursorVisible = true
local cursorBlinkTime = 0 -- Time for cursor blinking
local cursorBlinkInterval = 0.5 -- 0.5 seconds for blinking
local consoleOutput = {}
local originalPrint = print
local debuggerScrollY = 0  -- Tracks how much the debugger is scrolled
local debuggerMaxScroll = 0  -- Tracks the maximum scrollable height
local debuggerVisibleHeight = 115  -- Height of the visible debugger area
local debuggerLineHeight = 15  -- Height of each line of text

-- Undo/Redo stacks
local undoStack = {}
local redoStack = {}

local cursorIndex = 0

-- Override the print function
print = function(...)
    local message = ""
    for i = 1, select("#", ...) do
        message = message .. tostring(select(i, ...)) .. "\t"
    end
    table.insert(consoleOutput, message)
    originalPrint(...)  -- Call the original print function

    -- Update the maximum scrollable height
    debuggerMaxScroll = math.max(0, #consoleOutput * debuggerLineHeight - debuggerVisibleHeight)
end

local saveCodeButton = ButtonLibrary:new(150, 10, 100, 30, "Save", function()
    saveIDECode(textEditorContent)
end)

local openCodeButton = ButtonLibrary:new(290, 10, 100, 30, "Open", function()
    fileDialog.setFilter({ "lua", "txt", "json", "nyaproj"})
    fileDialog.open("project")
end)

local closeIDEButton = ButtonLibrary:new(love.graphics:getWidth() - 50, 10, 30, 30, "X", function()
    ideTest = false
end)

-- Colors for syntax highlighting
local syntaxColors = {
    keyword = {1, 0.2, 0.2},  -- Red for keywords
    functions = {0.2, 0.6, 1}, -- Blue for functions
    operator = {0.8, 0.8, 0}, -- Yellow for operators
    lovefunctions = {1, 0.5, 0.5},
    customlibs = {0.5,1,1},
    glsl = {0.337, 0.714, 0.761},
    default = {1, 1, 1}       -- White for normal text
}

local function clampCursor()
    cursorIndex = math.max(0, math.min(cursorIndex, #textEditorContent))
end

local function getLineStart(index)
    local before = textEditorContent:sub(1, index)
    local lastNewline = before:find("\n[^\n]*$") 
    return lastNewline and lastNewline or 0
end

local function getLineEnd(index)
    local after = textEditorContent:sub(index + 1)
    local nextNewline = after:find("\n")
    return nextNewline and (index + nextNewline - 1) or #textEditorContent
end

local function getCursorLineColumn()
    local before = textEditorContent:sub(1, cursorIndex)
    local lineStart = before:match("()\n[^\n]*$") or 1
    local column = cursorIndex - (lineStart - 1)
    return lineStart, column
end


-- Generic setup
function ide.load()
    -- Load and parse the syntax.json file
    local json = require("lib/dkjson")  -- Assuming dkjson.lua is in your project

    local file = love.filesystem.read("syntax.json")  -- Read the JSON file
    if file then
        syntax = json.decode(file)  -- Parse the JSON content into a Lua table
    else
        print("Failed to load syntax.json!")
    end

    table.insert(otherStuff, scriptNameTextBox)
    table.insert(otherStuff, openCodeButton)
    table.insert(otherStuff, saveCodeButton)

    fileDialog.setCallback(function(path)
        local content = love.filesystem.read(path)
        if not content then
            print("Failed to open file:", path)
            return
        end

        ide.updateTextEditorContent(content)
        cursorIndex = #content
        ide.updateCursorPosition()

        -- Update script name
        local name = path:match("([^/]+)%.")
        if name then
            scriptNameTextBox.text = name
        end
    end)
end

function ide.draw()
    ide.drawTextMode()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Files sidebar (all scripts)
    love.graphics.setColor(preferences.getColor("general", "primary"))
    love.graphics.rectangle("fill", 0, 50, 150, windowHeight - 50)

    -- Topbar
    love.graphics.setColor(preferences.getColor("topbar", "color"))
    love.graphics.rectangle("fill", 0, 0, windowWidth, 50)

    -- Debugger
    love.graphics.setColor(0.25, 0.25, 0.25)
    love.graphics.rectangle("fill", 0, windowHeight - debuggerVisibleHeight, windowWidth, debuggerVisibleHeight)

    -- Draw console output in the debugger section
    love.graphics.setColor(1, 1, 1)
    local debuggerX, debuggerY = 10, windowHeight - debuggerVisibleHeight + 10 - debuggerScrollY
    for i, message in ipairs(consoleOutput) do
        love.graphics.print(message, debuggerX, debuggerY)
        debuggerY = debuggerY + debuggerLineHeight
        if debuggerY > windowHeight - 10 then
            break  -- Stop drawing if we run out of space
        end
    end

    -- Draw scrollbar
    if debuggerMaxScroll > 0 then
        local scrollbarWidth = 5
        local scrollbarHeight = debuggerVisibleHeight * (debuggerVisibleHeight / (#consoleOutput * debuggerLineHeight))
        local scrollbarX = windowWidth - scrollbarWidth - 5
        local scrollbarY = windowHeight - debuggerVisibleHeight + (debuggerScrollY / debuggerMaxScroll) * (debuggerVisibleHeight - scrollbarHeight)

        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight)
    end

    -- Draw buttons and other UI elements
    saveCodeButton:draw()
    openCodeButton:draw()
    closeIDEButton:draw()
    closeIDEButton.x = love.graphics:getWidth() - 50

    fileDialog.draw()
    scriptNameTextBox.bgColor = preferences.getColor("textbox", "background")
    scriptNameTextBox.textColor = preferences.getColor("textbox", "textColor")
    scriptNameTextBox:draw()
end

-- Update function
function ide.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
   
   saveCodeButton:update(mouseX, mouseY)
   openCodeButton:update(mouseX, mouseY)
   scriptNameTextBox:update(dt) -- Update the textbox
   closeIDEButton:update(mouseX, mouseY)

   cursorBlinkTime = cursorBlinkTime + dt
    if cursorBlinkTime >= cursorBlinkInterval then
        cursorVisible = not cursorVisible
        cursorBlinkTime = 0
    end
end

function ide.createNode()

end

-- Handle mouse pressed events
function ide.mousepressed(x, y, button)
    saveCodeButton:mousepressed(x, y, button)
    openCodeButton:mousepressed(x, y, button)
    fileDialog.mousepressed(x, y, button)
    closeIDEButton:mousepressed(x,y,button)
    scriptNameTextBox:mousepressed(x, y, button)
end

-- Text mode rendering with syntax highlighting
function ide.drawTextMode()
    -- Save the current font to restore it later
    local previousFont = love.graphics.getFont()

    -- Set the JetBrains Mono font for the code editor
    love.graphics.setFont(font)

    local x, y = 175, 50
    local lineHeight = love.graphics.getFont():getHeight()
    
    for line in textEditorContent:gmatch("([^\n]*)\n?") do
        ide.drawHighlightedLine(line, x, y)
        y = y + lineHeight
    end

    -- Draw cursor if text editor is active
    if cursorVisible then
        love.graphics.setColor(1, 1, 1)
        love.graphics.line(cursorPos.x, cursorPos.y, cursorPos.x, cursorPos.y + lineHeight)  -- Draw blinking cursor
    end

    -- Draw selection if there's any selected text
    if selectedText ~= "" then
        love.graphics.setColor(0.2, 0.4, 0.8, 0.5)  -- Highlight color
        love.graphics.rectangle("fill", 175, cursorPos.y, love.graphics.getFont():getWidth(selectedText), lineHeight)
    end

    -- Restore the previous font to avoid affecting the rest of the UI
    love.graphics.setFont(previousFont)
end

-- Highlight a single line of text
function ide.drawHighlightedLine(line, x, y)
    local cursor = x

    -- Match words and operators
    for token in line:gmatch("[^%s]+") do
        local color = ide.getSyntaxColor(token)
        love.graphics.setColor(color)
        love.graphics.print(token, cursor, y)
        cursor = cursor + font:getWidth(token .. " ")  -- Use the JetBrains Mono font for width calculations
    end
end

function ide.wheelmoved(x, y)
    if y ~= 0 then
        -- Update the scroll position based on the mouse wheel movement
        debuggerScrollY = debuggerScrollY - y * debuggerLineHeight  -- Adjust scroll speed

        -- Clamp the scroll position to prevent scrolling too far
        debuggerMaxScroll = math.max(0, #consoleOutput * debuggerLineHeight - debuggerVisibleHeight)
        debuggerScrollY = math.max(0, math.min(debuggerScrollY, debuggerMaxScroll))
    end
end

function ide.clearConsole()
    consoleOutput = {}
    debuggerScrollY = 0
    debuggerMaxScroll = 0
end

function toggleComment(content)
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        if line:sub(1, 2) == "--" then
            table.insert(lines, line:sub(3))  -- Remove comment
        else
            table.insert(lines, "--" .. line)  -- Add comment
        end
    end
    return table.concat(lines, "\n")
end

-- Determine the color for a token based on syntax
function ide.getSyntaxColor(token)
    if syntax and table.contains(syntax.lua_keywords, token) then
        return syntaxColors.keyword
    elseif syntax and table.contains(syntax.lua_functions, token) then
        return syntaxColors.functions
    elseif syntax and table.contains(syntax.lua_operators, token) then
        return syntaxColors.operator
    elseif syntax and table.contains(syntax.functions.love, token) then
        return syntaxColors.lovefunctions
    elseif syntax and table.contains(syntax.customLibraries, token) then
        return syntaxColors.customlibs
    elseif syntax and table.contains(syntax.GLSL, token) then
        return syntaxColors.glsl
    else
        return syntaxColors.default
    end
end

function ide.textinput(text)
        if scriptNameTextBox.focused == true then
            scriptNameTextBox:textinput(text) -- Pass input to the textbox
        else
            -- Update cursor position when typing
            local fontWidth = love.graphics.getFont():getWidth(text)
            cursorPos.x = cursorPos.x + fontWidth
            textEditorContent = textEditorContent:sub(1, cursorIndex) .. text .. textEditorContent:sub(cursorIndex+1)
            cursorIndex = cursorIndex + #text
            ide.updateCursorPosition()

            ide.saveToUndoStack()
        end
end

-- Update the cursor position based on the current text content
function ide.updateCursorPosition()
    local before = textEditorContent:sub(1, cursorIndex)
    local lineCount = select(2, before:gsub("\n", "")) -- number of newlines before cursor
    local lastLine = before:match("([^\n]*)$") or ""

    cursorPos.x = 175 + font:getWidth(lastLine)
    cursorPos.y = 50 + lineCount * font:getHeight()
end

function ide.updateTextEditorContent(content)
    textEditorContent = content
end

function ide.keypressed(key, scancode, isrepeat)
         if scriptNameInput.isActive then
            handleScriptNameInput(key)
        else
            local fontWidth = love.graphics.getFont():getWidth(textEditorContent)
            if key == "backspace" and cursorIndex > 0 then
                textEditorContent =
                    textEditorContent:sub(1, cursorIndex - 1) ..
                    textEditorContent:sub(cursorIndex + 1)

                cursorIndex = cursorIndex - 1
                ide.updateCursorPosition()
                ide.saveToUndoStack()
            elseif key == "return" then
                -- Add a new line (newline character)
                textEditorContent = textEditorContent .. "\n"
                cursorPos.x = 175  -- Reset cursor x position after a newline
                cursorPos.y = cursorPos.y + love.graphics.getFont():getHeight()
                ide.saveToUndoStack()
            elseif key == "a" and love.keyboard.isDown("lctrl", "rctrl") then
                -- Select All
                selectedText = textEditorContent
            elseif key == "/" and love.keyboard.isDown("lctrl", "rctrl") then
                -- Toggle Comment
                textEditorContent = toggleComment(textEditorContent)
                ide.saveToUndoStack()
            elseif key == "z" and love.keyboard.isDown("lctrl", "rctrl") then
                -- Undo
                ide.undo()
            elseif key == "y" and love.keyboard.isDown("lctrl", "rctrl") then
                -- Redo
                ide.redo()
            elseif key == "left" then
                cursorIndex = cursorIndex - 1

            elseif key == "right" then
                cursorIndex = cursorIndex + 1

            elseif key == "home" then
                cursorIndex = getLineStart(cursorIndex)

            elseif key == "end" then
                cursorIndex = getLineEnd(cursorIndex)

            elseif key == "up" or key == "down" then
                local lineStart, column = getCursorLineColumn()

                if key == "up" and lineStart > 1 then
                    local prevLineEnd = lineStart - 2
                    local prevLineStart = getLineStart(prevLineEnd)
                    cursorIndex = math.min(prevLineStart + column - 1, prevLineEnd)

                elseif key == "down" then
                    local lineEnd = getLineEnd(cursorIndex)
                    if lineEnd < #textEditorContent then
                        local nextLineStart = lineEnd + 2
                        local nextLineEnd = getLineEnd(nextLineStart)
                        cursorIndex = math.min(nextLineStart + column - 1, nextLineEnd)
                    end
                end
            end

            clampCursor()
            ide.updateCursorPosition()

            if love.keyboard.isDown("lctrl", "rctrl") then
                if key == "left" then
                    local before = textEditorContent:sub(1, cursorIndex)
                    local s = before:match("()%W+%w*$") or before:match("()%w+$")
                    cursorIndex = (s or 1) - 1

                elseif key == "right" then
                    local after = textEditorContent:sub(cursorIndex + 1)
                    local e = after:match("^%w+()%W") or #after + 1
                    cursorIndex = cursorIndex + e
                end

                clampCursor()
                ide.updateCursorPosition()
                return
            end
        end
end

-- Save current text state to the undo stack
function ide.saveToUndoStack()
    table.insert(undoStack, textEditorContent)
    redoStack = {}  -- Clear redo stack when new changes are made
end

-- Perform undo action
function ide.undo()
    if #undoStack > 0 then
        local lastState = table.remove(undoStack)
        table.insert(redoStack, textEditorContent)
        textEditorContent = lastState
        ide.updateCursorPosition()
    end
end

-- Perform redo action
function ide.redo()
    if #redoStack > 0 then
        local lastState = table.remove(redoStack)
        table.insert(undoStack, textEditorContent)
        textEditorContent = lastState
        ide.updateCursorPosition()
    end
end

-- Utility to check if a table contains a value
function table.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

return ide