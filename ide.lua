local ide = {}
local fileDialog = require("lib/fileDialog")
local nodes = require("engine/nodes")

--[[
    TODO:
    1. Add support for shader coding
    2. Add the fucking visual coding
]]

-- Modes: "text" or "visual"
local mode = "text"
local editingMode = "luascript" -- lua or shaders(currently unused)
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

scriptNameTextBox = TextBox.new(0, 60, 150, 30, "Script Name", {0.8, 0.3, 0.6}, {1,1,1})

-- Editor states
local textEditorContent = ""
local cursorPos = {x = 175, y = 50} -- Track the cursor position
local selectedText = ""  -- Hold the selected text
local cursorVisible = true
local cursorBlinkTime = 0 -- Time for cursor blinking
local cursorBlinkInterval = 0.5 -- 0.5 seconds for blinking

local nodewinvis = false

-- Undo/Redo stacks
local undoStack = {}
local redoStack = {}

local saveCodeButton = ButtonLibrary:new(150, 10, 100, 30, "Save", function()
    saveIDECode(textEditorContent)
end)

local openCodeButton = ButtonLibrary:new(290, 10, 100, 30, "Open", function()
    fileDialog.open()
end)

local toggleModeButton = ButtonLibrary:new(10, 10, 100, 30, "Toggle Mode", function()
    if mode == "text" then
        mode = "visual"
    else
        mode = "text"
    end
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

    chooseNodeWin = window:new(50, 50, love.graphics:getWidth() - 100, love.graphics:getWidth() - 100)
end

-- Draw function to render the respective mode
function ide.draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    if mode == "text" then
        ide.drawTextMode()
    else 
        ide.drawVisualMode()
    end

    -- files sidebar(all scripts)
    love.graphics.setColor(customization.getColor("primary"))
    love.graphics.rectangle("fill", 0, 50, 150, windowHeight - 50)

    --topbar
    love.graphics.setColor(customization.getColor("topbar"))
    love.graphics.rectangle("fill", 0, 0, windowWidth, 50)

    --debugger
    love.graphics.setColor(0.25,0.25,0.25)
    love.graphics.rectangle("fill", 0, windowHeight - 125, windowWidth, 125)

    saveCodeButton:draw()
    toggleModeButton:draw()
    openCodeButton:draw()
    closeIDEButton:draw()
    closeIDEButton.x = love.graphics:getWidth() - 50

    fileDialog.draw()
    scriptNameTextBox:draw()

    if nodewinvis then
            chooseNodeWin:draw()
    end
end

-- Update function
function ide.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
   
   saveCodeButton:update(mouseX, mouseY)
   openCodeButton:update(mouseX, mouseY)
   toggleModeButton:update(mouseX, mouseY)
   scriptNameTextBox:update(dt) -- Update the textbox
   closeIDEButton:update(mouseX, mouseY)

   if nodewinvis then
            chooseNodeWin:update(dt)
    end

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
    toggleModeButton:mousepressed(x, y, button)
    fileDialog.mousepressed(x, y, button)
    closeIDEButton:mousepressed(x,y,button)

    scriptNameTextBox:mousepressed(x, y, button)
    if button == 2 then
        if mode == "visual" then

        end
    end
end

function ide.drawVisualMode()

end

-- Text mode rendering with syntax highlighting
function ide.drawTextMode()
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
end

-- Highlight a single line of text
function ide.drawHighlightedLine(line, x, y)
    local cursor = x

    -- Match words and operators
    for token in line:gmatch("[^%s]+") do
        local color = ide.getSyntaxColor(token)
        love.graphics.setColor(color)
        love.graphics.print(token, cursor, y)
        cursor = cursor + love.graphics.getFont():getWidth(token .. " ")
    end
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
    if mode == "text" then
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
end

-- Update the cursor position based on the current text content
function ide.updateCursorPosition()
    local fontWidth = love.graphics.getFont():getWidth(textEditorContent)
    local lineHeight = love.graphics.getFont():getHeight()

    -- Count the number of newlines in the content to determine the number of lines
    local lineCount = 0
    for _ in textEditorContent:gmatch("\n") do
        lineCount = lineCount + 1
    end

    -- Update the cursor position
    cursorPos.x = 175 + fontWidth  -- Update the x position based on the width of the content
    cursorPos.y = 50 + lineHeight * lineCount  -- Update the y position based on the number of lines
end

function ide.updateTextEditorContent(content)
    textEditorContent = content
end

function ide.keypressed(key, scancode, isrepeat)
    if mode == "text" then
         if scriptNameInput.isActive then
            handleScriptNameInput(key)
        else
            local fontWidth = love.graphics.getFont():getWidth(textEditorContent)
            if key == "backspace" then
                if selectedText ~= "" then
                    textEditorContent = ""
                    selectedText = ""
                    cursorPos.x = 175
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
