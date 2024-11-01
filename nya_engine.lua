local NyaEngine = {}

-- Dependencies
local Scene = require("scene")
local GameObject = require("game_object")

-- Initialization of Nya Engine components
function NyaEngine:init()
    self.scenes = {}
    self.activeScene = nil
    self.physicsWorld = love.physics.newWorld(0, 9.81 * 64, true)

    -- Set up collision callback
    self.physicsWorld:setCallbacks(
        function(a, b, coll)
            -- Collision start callback
            print("Collision started between " .. tostring(a:getUserData()) .. " and " .. tostring(b:getUserData()))
        end,
        function(a, b, coll)
            -- Collision end callback
            print("Collision ended between " .. tostring(a:getUserData()) .. " and " .. tostring(b:getUserData()))
        end
    )

    -- Add a default scene
    self:addScene("default", Scene:new(self.physicsWorld))
    self:switchScene("default")
end

-- Adds a scene to the engine
function NyaEngine:addScene(name, scene)
    self.scenes[name] = scene
end

-- Create a new object
function NyaEngine:createObject(x, y)
    local obj = GameObject:new(x or 100, y or 100, 50, 50)
    self.activeScene:addObject(obj)
    return obj
end

-- Remove an object from the active scene
function NyaEngine:removeObject(obj)
    self.activeScene:removeObject(obj)
end

-- Switch scenes in the engine
function NyaEngine:switchScene(name)
    if self.scenes[name] then
        self.activeScene = self.scenes[name]
    else
        print("Scene " .. name .. " not found.")
    end
end

-- Update loop for the engine
function NyaEngine:update(dt)
    if self.activeScene then
        self.physicsWorld:update(dt)  -- Update the physics world
        self.activeScene:update(dt)
    end
end

-- Render loop for the engine
function NyaEngine:render()
    if self.activeScene then
        self.activeScene:render()
    end
end

-- Key press handler
function NyaEngine:keypressed(key)
    if self.activeScene then
        self.activeScene:keypressed(key)
    end
end

return NyaEngine
