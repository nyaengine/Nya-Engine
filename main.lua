local NyaEngine = require("nya_engine")
local UI = require("ui")
local PhysicsObject = require("physics_object")

function love.load()
    -- Initialize Nya Engine
    NyaEngine:init()

    -- Create a ground platform (static)
    local ground = PhysicsObject:new(NyaEngine.physicsWorld, 400, 550, 800, 50, "static")
    NyaEngine.activeScene:addObject(ground)

    -- Create a dynamic falling box
    local box = PhysicsObject:new(NyaEngine.physicsWorld, 400, 100, 50, 50, "dynamic")
    NyaEngine.activeScene:addObject(box)

    -- Initialize the UI with Nya Engine's reference
    UI:init(NyaEngine)
end

function love.update(dt)
    -- Update Nya Engine and UI
    NyaEngine:update(dt)
    UI:update(dt)
end

function love.draw()
    -- Render Nya Engine and UI
    NyaEngine:render()
    UI:render()
end

function love.mousepressed(x, y, button)
    -- Pass mouse events to the UI
    UI:mousepressed(x, y, button)
end

function love.keypressed(key)
    -- Pass key events to both the engine and UI
    NyaEngine:keypressed(key)
    UI:keypressed(key)
end
