local NyaEngine = require("nya_engine")
local UI = require("ui")
local PhysicsObject = require("physics_object")
local Camera = require("camera")
local camera

function love.load()
    -- Initialize Nya Engine
    NyaEngine:init()

    -- Initialize camera
    camera = Camera:new()
    -- Set the initial camera position
    camera:setPosition(0, 0)

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

    -- Camera movement controls (arrow keys or WASD)
    local speed = 300 * dt
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        camera:move(0, -speed)
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        camera:move(0, speed)
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        camera:move(-speed, 0)
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        camera:move(speed, 0)
    end

    -- Zoom controls
    if love.keyboard.isDown("z") then
        camera:setZoom(camera.scale + 0.1 * dt)
    end
    if love.keyboard.isDown("x") then
        camera:setZoom(camera.scale - 0.1 * dt)
    end

    -- Update camera (smooth follow if target is set)
    camera:update(dt)
end

function love.draw()
    -- Apply camera transformations
    camera:apply()

    -- Reset the camera transformations
    camera:reset()

    -- Render Nya Engine and UI
    NyaEngine:render()
    UI:render()
end

function love.mousepressed(x, y, button)
    -- Pass mouse events to the UI
    UI:mousepressed(x, y, button)
end

function love.keypressed(key)
    
end

function love.mousereleased(x, y, button)
    UI:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    UI:mousemoved(x, y, dx, dy)
end
