local ide = {}

-- Modes: "text" or "visual"
local mode = "text"
local syntax  -- Will hold the parsed syntax data

-- Editor states
local textEditorContent = "-- Start coding here\n"
local visualEditorComponents = {} -- Table to store visual mode components like nodes, connections, etc.

-- Colors for syntax highlighting
local syntaxColors = {
    keyword = {1, 0.2, 0.2},  -- Red for keywords
    functions = {0.2, 0.6, 1}, -- Blue for functions
    operator = {0.8, 0.8, 0}, -- Yellow for operators
    lovefunctions = {1, 0.5, 0.5},
    default = {1, 1, 1}       -- White for normal text
}

-- Generic setup
function ide.load()
    love.window.setTitle("IDE - Text and Visual Coding Mode")
    love.graphics.setFont(love.graphics.newFont(14))

    -- Load and parse the syntax.json file
    local json = require("lib/dkjson")  -- Assuming dkjson.lua is in your project

    local file = love.filesystem.read("syntax.json")  -- Read the JSON file
    if file then
        syntax = json.decode(file)  -- Parse the JSON content into a Lua table
    else
        print("Failed to load syntax.json!")
    end
end

-- Draw function to render the respective mode
function ide.draw()
    if mode == "text" then
        ide.drawTextMode()
    elseif mode == "visual" then
        ide.drawVisualMode()
    end

    -- Draw a toggle button
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", 10, 10, 100, 30)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Toggle Mode", 20, 15)
end

-- Update function
function ide.update(dt)
    -- Update logic for the current mode
    if mode == "visual" then
        ide.updateVisualMode(dt)
    end
end

-- Handle mouse pressed events
function ide.mousepressed(x, y, button)
    -- Check if toggle button is clicked
    if x >= 10 and x <= 110 and y >= 10 and y <= 40 then
        if mode == "text" then
            mode = "visual"
        else
            mode = "text"
        end
    end

    if mode == "visual" then
        ide.handleVisualMousePressed(x, y, button)
    end
end

-- Text mode rendering with syntax highlighting
function ide.drawTextMode()
    local x, y = 10, 50
    local lineHeight = love.graphics.getFont():getHeight()
    
    for line in textEditorContent:gmatch("([^\n]*)\n?") do
        ide.drawHighlightedLine(line, x, y)
        y = y + lineHeight
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
    else
        return syntaxColors.default
    end
end

function ide.textinput(text)
    if mode == "text" then
        textEditorContent = textEditorContent .. text
    end
end

function ide.keypressed(key, scancode, isrepeat)
    if mode == "text" then
        if key == "backspace" then
            -- Remove the last character in textEditorContent
            textEditorContent = textEditorContent:sub(1, -2)
        elseif key == "return" then
            -- Add a new line (newline character)
            textEditorContent = textEditorContent .. "\n"
        end
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

-- Visual mode rendering (placeholder for further development)
function ide.drawVisualMode()
    love.graphics.setColor(1, 1, 1, 1)
    for _, component in ipairs(visualEditorComponents) do
        love.graphics.rectangle("fill", component.x, component.y, component.width, component.height)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf(component.name, component.x + 5, component.y + 5, component.width - 10, "center")
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Visual mode update logic
function ide.updateVisualMode(dt)
    -- Placeholder for visual components' behavior
end

-- Handle mouse interactions in visual mode
function ide.handleVisualMousePressed(x, y, button)
    -- Example: Add a new visual component on click
    table.insert(visualEditorComponents, {
        name = "Node",
        x = x,
        y = y,
        width = 100,
        height = 50
    })
end

return ide
