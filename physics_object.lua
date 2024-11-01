local GameObject = require("game_object")
local PhysicsObject = setmetatable({}, { __index = GameObject })
PhysicsObject.__index = PhysicsObject

-- Constructor for physics-enabled object
function PhysicsObject:new(world, x, y, width, height, type)
    local obj = GameObject.new(self, x, y, width, height)  -- Call base constructor
    setmetatable(obj, PhysicsObject)
    
    obj.body = love.physics.newBody(world, x, y, type or "dynamic")
    obj.shape = love.physics.newRectangleShape(width, height)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape)

    return obj
end

-- Update position based on physics body
function PhysicsObject:update(dt)
    -- Physics objects automatically update through the physics engine
end

-- Render the physics object
function PhysicsObject:render()
    love.graphics.setColor(self.color)
    love.graphics.push()
    love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.rotate(self.body:getAngle())
    love.graphics.rectangle("fill", -self.width / 2, -self.height / 2, self.width, self.height)
    love.graphics.pop()
end

function PhysicsObject:destroy()
    if self.body then
        self.body:destroy()  -- Destroy the physics body if it exists
    end
end

return PhysicsObject
