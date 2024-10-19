-- main.lua

local Engine = require("engine.engine")
local UIManager = require("engine.ui.ui_manager")
local UICreator = require("ui_creator")
local Camera = require("engine.camera")

local uiCreator
local camera

function love.load()
    Engine:init()
    uiCreator = UICreator:new()
    camera = Camera:new()
    
    -- Optional: Set camera bounds to keep within a specific area
    camera:setBounds(0, 0, 2000, 2000)  -- Example boundaries
end

function love.update(dt)
    Engine:update(dt)
    uiCreator:update(dt)
    camera:update(dt)

    -- Camera control (arrow keys for panning, +/- for zoom)
    if love.keyboard.isDown("left") then
        camera:move(-200 * dt, 0)
    elseif love.keyboard.isDown("right") then
        camera:move(200 * dt, 0)
    end

    if love.keyboard.isDown("up") then
        camera:move(0, -200 * dt)
    elseif love.keyboard.isDown("down") then
        camera:move(0, 200 * dt)
    end

    -- Zoom in/out with "+" and "-" keys
    if love.keyboard.isDown("=") then  -- "+" key is often the same as "=" without shift
        camera:zoom(1.1)
    elseif love.keyboard.isDown("-") then
        camera:zoom(0.9)
    end
end

function love.draw()
    -- Draw game objects within the camera's view
    camera:attach()    
    Engine:draw()      -- Draw all game elements affected by the camera
    camera:detach()    -- End camera transformations

    -- Draw UI elements, ensuring they are fixed on the screen
    uiCreator:draw()   
end

function love.mousepressed(x, y, button)
    -- Adjust mouse coordinates for camera transformation only when interacting with game objects
    local camX, camY = camera.x + x / camera.scale, camera.y + y / camera.scale
    uiCreator:mousepressed(x, y, button)  -- Use raw coordinates for UI interaction
end

function love.textinput(text)
    UIManager:textinput(text)  -- Handles text input for text boxes
end

function love.keypressed(key)
    UIManager:keypressed(key)  -- Handles key presses for UI elements
end
