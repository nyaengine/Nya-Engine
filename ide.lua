local ide = {}
local nodes = require("engine/nodes")

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
    fileDialog.open()
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
            textEditorContent = textEditorContent .. text

            ide.saveToUndoStack()
        end
end

-- Update the cursor position based on the current text content
function ide.updateCursorPosition()
    local fontWidth = font:getWidth(textEditorContent)  -- Use the JetBrains Mono font for width calculations
    local lineHeight = font:getHeight()  -- Use the height of the JetBrains Mono font

    -- Count the number of newlines in the content to determine the number of lines
    local lineCount = 0
    for _ in textEditorContent:gmatch("\n") do
        lineCount = lineCount + 1
    end

    -- Update the cursor position
    cursorPos.x = 180 + fontWidth  -- Update the x position based on the width of the content
    cursorPos.y = 50 + lineHeight * lineCount  -- Update the y position based on the number of lines
end

function ide.updateTextEditorContent(content)
    textEditorContent = content
end

function ide.keypressed(key, scancode, isrepeat)
         if scriptNameInput.isActive then
            handleScriptNameInput(key)
        else
            local fontWidth = love.graphics.getFont():getWidth(textEditorContent)
            if key == "backspace" then
                if selectedText ~= "" then
                    textEditorContent = ""
                    selectedText = ""
                    cursorPos.x = 180
                    cursorPos.y = 50
                    ide.saveToUndoStack()
                else
                    -- Remove one character from the end of textEditorContent
                    textEditorContent = textEditorContent:sub(1, -2)
                    cursorPos.x = cursorPos.x - love.graphics.getFont():getWidth(textEditorContent:sub(-1))
                    ide.saveToUndoStack()
                end
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