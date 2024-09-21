-- particle_system.lua
local ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

function ParticleSystem:new(image, config)
    local ps = setmetatable({}, ParticleSystem)

    -- Particle system uses LOVE's built-in system for drawing particles
    ps.system = love.graphics.newParticleSystem(image, config.maxParticles or 100)
    
    -- Set defaults and allow customizations through config table
    ps.system:setParticleLifetime(config.minLifetime or 1, config.maxLifetime or 2) -- Life in seconds
    ps.system:setEmissionRate(config.emissionRate or 10)
    ps.system:setSizeVariation(config.sizeVariation or 1)
    ps.system:setLinearAcceleration(
        config.minSpeedX or -200, config.minSpeedY or -200,
        config.maxSpeedX or 200, config.maxSpeedY or 200
    )
    ps.system:setColors(
        config.startColor or {1, 1, 1, 1}, -- Start color (R, G, B, A)
        config.endColor or {1, 1, 1, 0}   -- End color (R, G, B, A)
    )
    ps.system:setSizes(config.startSize or 1, config.endSize or 0.1) -- Size from start to end
    ps.system:setSpread(config.spread or math.pi * 2) -- Emit in all directions by default
    ps.system:setSpeed(config.minSpeed or 100, config.maxSpeed or 200)
    ps.system:setRotation(config.rotationMin or 0, config.rotationMax or math.pi * 2)
    
    -- Optionally set the emission area
    if config.emissionArea then
        ps.system:setEmissionArea(unpack(config.emissionArea)) -- Shape, dx, dy, angle, directionRelativeToRotation
    end
    
    return ps
end

function ParticleSystem:start()
    self.system:start()
end

function ParticleSystem:stop()
    self.system:stop()
end

function ParticleSystem:update(dt)
    self.system:update(dt)
end

function ParticleSystem:draw(x, y)
    love.graphics.draw(self.system, x, y)
end

return ParticleSystem
