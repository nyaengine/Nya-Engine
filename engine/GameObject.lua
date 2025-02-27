GameObject = {}
GameObject.__index = GameObject

function GameObject:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    local obj = setmetatable(params or {}, GameObject)
    obj.children = {} -- Initialize the children table

    -- Default properties
    o.x = o.x or 0
    o.y = o.y or 0
    o.width = o.width or 0
    o.height = o.height or 0

    -- Initialize physics properties
    o.velocityX = velocityX or  0
    o.velocityY = velocityY or 0
    o.accelerationX = o.accelerationX or 0
    o.accelerationY = o.accelerationY or 0
    o.mass = o.mass or 1
    o.gravity = o.gravity or 500  -- acceleration due to gravity, adjust as needed

    return o
end

-- Apply force to the object (useful for handling things like gravity or user input)
function GameObject:applyForce(fx, fy)
    self.accelerationX = self.accelerationX + fx / self.mass
    self.accelerationY = self.accelerationY + fy / self.mass
end

function GameObject:update(dt)
    -- Apply gravity
    self:applyForce(0, self.gravity)

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