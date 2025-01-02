local ide = {}

-- Modes: "text" or "visual"
local mode = "text"
local syntax  -- Will hold the parsed syntax data

-- Editor states
local textEditorContent = "-- Start coding here\n"
local visualEditorComponents = {} -- Table to store visual mode components like nodes, connections, etc.
local connections = {} -- Store connections between nodes

local availableModules = {
    lua = {
        math = { "sin", "cos", "abs", "sqrt" },
        string = { "sub", "gsub", "find", "match" },
        table = { "insert", "remove", "sort" }
    },
    love = {
        graphics = { "draw", "line", "rectangle", "circle" },
        audio = { "newSource", "play", "stop" },
        timer = { "after", "every", "getTime" }
    }
}

-- Colors for syntax highlighting
local syntaxColors = {
    keyword = {1, 0.2, 0.2},  -- Red for keywords
    functions = {0.2, 0.6, 1}, -- Blue for functions
    operator = {0.8, 0.8, 0}, -- Yellow for operators
    lovefunctions = {1, 0.5, 0.5},
    customlibs = {0.5,1,1},
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
    elseif syntax and table.contains(syntax.functions.audio, token) then
        return syntaxColors.lovefunctions
    elseif syntax and table.contains(syntax.functions.graphics, token) then
        return syntaxColors.lovefunctions
    elseif syntax and table.contains(syntax.customLibraries, token) then
        return syntaxColors.customlibs
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

-- Visual mode rendering (with module nodes)
function ide.drawVisualMode()
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Draw connections between nodes
    for _, connection in ipairs(connections) do
        love.graphics.setColor(0, 1, 0, 1)  -- Green for connections
        love.graphics.line(connection[1].x + connection[1].width / 2, connection[1].y + connection[1].height / 2,
                            connection[2].x + connection[2].width / 2, connection[2].y + connection[2].height / 2)
    end
    
    -- Draw each component (node)
    for _, component in ipairs(visualEditorComponents) do
        love.graphics.setColor(0, 0, 1, 1)  -- Blue for nodes
        love.graphics.rectangle("fill", component.x, component.y, component.width, component.height)
        love.graphics.setColor(0, 0, 0, 1)  -- Black text for labels
        love.graphics.printf(component.name, component.x + 5, component.y + 5, component.width - 10, "center")
    end
end

-- Visual mode update logic (dragging and handling interactions)
function ide.updateVisualMode(dt)
    -- Placeholder for visual components' behavior (e.g., dragging)
end

-- Handle mouse interactions in visual mode (add nodes, connect them)
function ide.handleVisualMousePressed(x, y, button)
    if button == 1 then  -- Left mouse button
        -- Check if clicking on an existing node (for dragging or selecting)
        for _, component in ipairs(visualEditorComponents) do
            if x >= component.x and x <= component.x + component.width and
               y >= component.y and y <= component.y + component.height then
                -- Add logic for dragging or selecting nodes
                return
            end
        end

        -- Add a new module node on click (like math or love.graphics)
        local moduleX, moduleY = x - 50, y - 25
        local moduleNode = { name = "math", x = moduleX, y = moduleY, width = 100, height = 50, type = "module" }
        table.insert(visualEditorComponents, moduleNode)
    elseif button == 2 then  -- Right mouse button (for connecting nodes)
        -- Add connection logic here (e.g., connect two nodes by adding an entry in the connections table)
    end
end

-- Function for adding function nodes under a module
function ide.addFunctionNode(moduleName, functionName, x, y)
    table.insert(visualEditorComponents, {
        name = functionName,
        x = x,
        y = y,
        width = 100,
        height = 50,
        module = moduleName,
        type = "function"
    })
end

return ide
