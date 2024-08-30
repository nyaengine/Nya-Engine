-- engine/engine.lua

local Entity = require("engine.entity")
local Physics = require("engine.physics")

local Engine = {
    entities = {}
}

-- Initialize the engine
function Engine:init()
    self.entities = {}
end

-- Create a new entity
function Engine:createEntity(params)
    local entity = Entity:new(params)
    table.insert(self.entities, entity)
    return entity
end

-- Update game state
function Engine:update(dt)
    -- Update all entities
    for _, entity in ipairs(self.entities) do
        entity:update(dt)
    end
    
    -- Simple physics
    Physics:resolveCollisions(self.entities)
end

-- Draw entities
function Engine:draw()
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end

return Engine
