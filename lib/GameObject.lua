GameObject = {}
GameObject.__index = GameObject

local Physics = require("lib.Physics")
local _nextPhysicsId = 0
function GameObject:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    local obj = o
    obj.children = obj.children or {} -- Initialize the children table

    -- Default properties
    o.x = o.x or 0
    o.y = o.y or 0
    o.width = o.width or 0
    o.height = o.height or 0

    -- Initialize physics properties (used when not using love.physics)
    o.velocityX = o.velocityX or  0
    o.velocityY = o.velocityY or 0
    o.accelerationX = o.accelerationX or 0
    o.accelerationY = o.accelerationY or 0
    o.mass = o.mass or 1
    o.gravity = o.gravity or 500  -- acceleration due to gravity, adjust as needed

    -- If requested, create a physics body via the Physics library
    if o.usePhysics then
        _nextPhysicsId = _nextPhysicsId + 1
        local id = "go_" .. tostring(_nextPhysicsId)
        o.physicsId = id
        local opts = {}
        if o.static or o.isStatic then opts.static = true end
        Physics.addRectangle(id, o.x, o.y, o.width, o.height, opts)
        Physics.onCollision(id, function(selfData, otherData, contact)
            if o.onCollision then pcall(o.onCollision, o, otherData, contact) end
        end)
    end

    return o
end

function GameObject:update(dt)
    -- If using the physics library, sync position from the physics body
    if self.physicsId then
        local body = Physics.getBody(self.physicsId)
        if body then
            local bx, by = body:getX(), body:getY()
            -- Physics bodies are centered; convert to top-left
            self.x = bx - (self.width or 0) / 2
            self.y = by - (self.height or 0) / 2
            return
        end
    end

    -- Update velocity based on acceleration
    self.velocityX = self.velocityX + self.accelerationX * dt
    self.velocityY = self.velocityY + self.accelerationY * dt

    -- Update position based on velocity
    self.x = self.x + self.velocityX * dt
    self.y = self.y + self.velocityY * dt

    -- Simple friction to slow down velocity (optional)
    self.velocityX = self.velocityX * 0.99
    self.velocityY = self.velocityY * 0.99

    -- Reset accelerations after each update
    self.accelerationX = 0
    self.accelerationY = 0
end

function GameObject:enablePhysics(opts)
    if self.physicsId then return end
    _nextPhysicsId = _nextPhysicsId + 1
    local id = "go_" .. tostring(_nextPhysicsId)
    self.physicsId = id
    opts = opts or {}
    if self.static or self.isStatic then opts.static = true end
    Physics.addRectangle(id, self.x, self.y, self.width, self.height, opts)
    Physics.onCollision(id, function(selfData, otherData, contact)
        if self.onCollision then pcall(self.onCollision, self, otherData, contact) end
    end)
end

function GameObject:disablePhysics()
    if not self.physicsId then return end
    Physics.remove(self.physicsId)
    self.physicsId = nil
end

function GameObject:addChild(child)
    table.insert(self.children, child)
    child.parent = self
end

function GameObject:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            child.parent = nil
            break
        end
    end
end

function drawObjectList(objects, startY, indent)
    for i, obj in ipairs(objects) do
        if not obj then
            print("Error: Object at index " .. i .. " is nil.")
            return
        end

        local objectName = obj.name or "Unnamed Object" -- Fallback for nil names
        local labelX, labelY = 10 + indent, startY + (i - 1) * 20
        local labelWidth, labelHeight = 120, 20

        -- Highlight selected label
        if obj == selectedObject then
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
            love.graphics.rectangle("fill", labelX, labelY, labelWidth, labelHeight)
        end

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(objectName, labelX, labelY)

        -- Recursively draw children (if they exist)
        if obj.children and #obj.children > 0 then
            drawObjectList(obj.children, labelY + 20, indent + 20)
        end
    end
end

function GameObject:draw()
    if self.texture then
        local txtr = love.graphics.newImage(self.texture)
        -- Calculate scaling factors based on the desired width and height
        local scaleX = self.width / txtr:getWidth()
        local scaleY = self.height / txtr:getHeight()
        
        -- Draw the texture with scaling applied
        love.graphics.draw(txtr, self.x, self.y, 0, scaleX, scaleY)
    else
        love.graphics.setColor(1, 1, 1) -- white color for the square
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
end

function GameObject:isClicked(x, y)
    return x >= self.x and x <= (self.x + self.width) and
           y >= self.y and y <= (self.y + self.height)
end

function GameObject:checkCollision(other)
    return self.x < other.x + other.width and
           other.x < self.x + self.width and
           self.y < other.y + other.height and
           other.y < self.y + self.height
end

-- Handle collision response to prevent movement overlap
function GameObject:resolveCollision(other)
    if self:checkCollision(other) then
        self.isColliding = true

        -- Calculate overlap on each axis
        local overlapX = math.min(self.x + self.width - other.x, other.x + other.width - self.x)
        local overlapY = math.min(self.y + self.height - other.y, other.y + other.height - self.y)

        -- Resolve the smallest overlap to separate the objects
        if overlapX < overlapY then
            -- Push left or right
            if self.x < other.x then
                self.x = self.x - overlapX
            else
                self.x = self.x + overlapX
            end
        else
            -- Push up or down
            if self.y < other.y then
                self.y = self.y - overlapY
            else
                self.y = self.y + overlapY
            end
        end
    else
        self.isColliding = false
    end
end

return GameObject