local buttons = {}
local isPlaying = false
local json = require("dkjson") -- You'll need a JSON library
local Button = require('src/ui/button')

function love.keypressed(key)
    if key == "space" then
        isPlaying = not isPlaying
    end
end

function saveProject(filename)
    local data = {
        -- Store game objects, scripts, and UI configurations
    }
    love.filesystem.write(filename, json.encode(data))
end

function loadProject(filename)
    local contents = love.filesystem.read(filename)
    local data = json.decode(contents)
    -- Rebuild the scene from the loaded data
end


function love.load()
    table.insert(buttons, Button:new(100, 100, 200, 50, "Click Me"))
end

function love.update(dt)
    local mx, my = love.mouse.getPosition()
    for _, button in ipairs(buttons) do
        button:update(mx, my)
    end
end

function love.draw()
    for _, button in ipairs(buttons) do
        button:draw()
    end
end
