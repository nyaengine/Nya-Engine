-- engine/engine.lua

local Entity = require("engine.entity")
local Physics = require("engine.physics")
local ParticleSystem = require("engine.particle_system")

local Engine = {
    entities = {},
    particleSystems = {}
}

-- Initialize the engine
function Engine:init()
    self.entities = {}
    self.particleSystems = {} -- Initialize particle systems container
end

-- Create a new entity
function Engine:createEntity(params)
    local entity = Entity:new(params)
    table.insert(self.entities, entity)
    return entity
end

-- Create a new particle system
function Engine:createParticleSystem(image, config)
    local particleSystem = ParticleSystem:new(image, config)
    table.insert(self.particleSystems, particleSystem)
    return particleSystem
end

-- Update game state
function Engine:update(dt)
    -- Update all entities
    for _, entity in ipairs(self.entities) do
        entity:update(dt)
    end
    
    -- Update all particle systems
    for _, particleSystem in ipairs(self.particleSystems) do
        particleSystem:update(dt)
    end

    -- Simple physics
    Physics:resolveCollisions(self.entities)
end

-- Draw entities and particle systems
function Engine:draw()
    -- Draw all entities
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end

    -- Draw all particle systems
    for _, particleSystem in ipairs(self.particleSystems) do
        -- You can specify where to draw the particles or tie them to an entity
        particleSystem:draw(400, 300) -- Example, replace with desired position or entity linkage
    end
end

return Engine
