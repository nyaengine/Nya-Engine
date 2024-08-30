-- engine/entity.lua

local Entity = {}
Entity.__index = Entity

function Entity:new(params)
    local instance = {
        x = params.x or 0,
        y = params.y or 0,
        width = params.width or 50,
        height = params.height or 50,
        color = params.color or {1, 1, 1},
        speed = params.speed or 100,
        dx = 0,
        dy = 0
    }
    setmetatable(instance, Entity)
    return instance
end

function Entity:update(dt)
    -- Simple movement logic (for demonstration)
    if love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
    elseif love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
    end
    if love.keyboard.isDown("down") then
        self.y = self.y + self.speed * dt
    elseif love.keyboard.isDown("up") then
        self.y = self.y - self.speed * dt
    end
end

function Entity:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Entity
