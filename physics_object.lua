local PhysicsObject = {}
PhysicsObject.__index = PhysicsObject

-- Constructor for physics-enabled object
function PhysicsObject:new(world, x, y, width, height, type)
    local obj = setmetatable({}, PhysicsObject)
    
    -- Set default properties
    obj.width = width or 32
    obj.height = height or 32
    obj.color = {1, 0.8, 0.8}  -- Light pink for visibility

    -- Create physics body and shape
    obj.body = love.physics.newBody(world, x, y, type or "dynamic")  -- 'dynamic', 'static', or 'kinematic'
    obj.shape = love.physics.newRectangleShape(obj.width, obj.height)
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

-- Handle object removal
function PhysicsObject:destroy()
    self.body:destroy()
end

return PhysicsObject
