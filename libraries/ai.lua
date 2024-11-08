-- ai.lua
-- Simple AI Library for LÖVE 2D

local AI = {}
AI.__index = AI

-- Creates a new enemy entity with position and behavior
function AI.new(x, y, behavior)
    local self = setmetatable({}, AI)
    self.x = x
    self.y = y
    self.speed = 100
    self.behavior = behavior or "follow"
    self.target = nil  -- Target to follow, like the player
    self.patrolPoints = {}
    self.patrolIndex = 1
    self.direction = 1  -- Used in patrolling between two points
    return self
end

-- Sets the target (usually the player) for the entity to follow
function AI:setTarget(target)
    self.target = target
end

-- Sets patrol points for patrolling behavior
function AI:setPatrolPoints(points)
    self.patrolPoints = points
    if #points > 0 then
        self.x, self.y = points[1][1], points[1][2]
    end
end

-- Distance calculation between two points
local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Follow the player or target
function AI:follow(dt)
    if self.target then
        local dx, dy = self.target.x - self.x, self.target.y - self.y
        local dist = distance(self.x, self.y, self.target.x, self.target.y)

        if dist > 0 then
            self.x = self.x + (dx / dist) * self.speed * dt
            self.y = self.y + (dy / dist) * self.speed * dt
        end
    end
end

-- Patrol between a set of points
function AI:patrol(dt)
    if #self.patrolPoints > 1 then
        local targetX, targetY = self.patrolPoints[self.patrolIndex][1], self.patrolPoints[self.patrolIndex][2]
        local dist = distance(self.x, self.y, targetX, targetY)

        if dist > 5 then
            self.x = self.x + (targetX - self.x) / dist * self.speed * dt
            self.y = self.y + (targetY - self.y) / dist * self.speed * dt
        else
            -- Move to the next patrol point
            self.patrolIndex = self.patrolIndex + self.direction
            if self.patrolIndex > #self.patrolPoints then
                self.patrolIndex = #self.patrolPoints - 1
                self.direction = -1
            elseif self.patrolIndex < 1 then
                self.patrolIndex = 2
                self.direction = 1
            end
        end
    end
end

-- Simple avoid behavior - moves in the opposite direction of target
function AI:avoid(dt)
    if self.target then
        local dx, dy = self.x - self.target.x, self.y - self.target.y
        local dist = distance(self.x, self.y, self.target.x, self.target.y)

        if dist > 0 and dist < 200 then -- Only avoid if within range
            self.x = self.x + (dx / dist) * self.speed * dt
            self.y = self.y + (dy / dist) * self.speed * dt
        end
    end
end

-- Update function for AI, choosing the appropriate behavior
function AI:update(dt)
    if self.behavior == "follow" then
        self:follow(dt)
    elseif self.behavior == "patrol" then
        self:patrol(dt)
    elseif self.behavior == "avoid" then
        self:avoid(dt)
    end
end

-- Draw the entity for debugging
function AI:draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", self.x, self.y, 10)
end

return AI
