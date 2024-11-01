local NyaEngine = require("nya_engine")
local UI = require("ui")
local PhysicsObject = require("physics_object")

function love.load()
    -- Initialize Nya Engine
    NyaEngine:init()

    -- Add ambient sound near a specific object (e.g., waterfall sound)
    local waterfallSound = NyaEngine.audio:addSound("sounds/waterfall.ogg", 500, 300, false)
    NyaEngine.audio:playSound(waterfallSound)

    -- Add a sound that plays on event (e.g., object collision)
    local collisionSound = NyaEngine.audio:addSound("sounds/collision.ogg", 0, 0, false)

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
    if key == "space" then
        -- Play collision sound at player's position for demonstration
        local playerX, playerY = NyaEngine:getPlayerPosition()
        NyaEngine.audio:setSoundPosition(collisionSound, playerX, playerY)
        NyaEngine.audio:playSound(collisionSound)
    end
end
