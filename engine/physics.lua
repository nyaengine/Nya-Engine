-- engine/physics.lua

local Physics = {}

function Physics:resolveCollisions(entities)
    for i = 1, #entities do
        for j = i + 1, #entities do
            local e1 = entities[i]
            local e2 = entities[j]
            
            if self:checkCollision(e1, e2) then
                -- Simple collision response: stop movement
                e1.dx, e1.dy = 0, 0
                e2.dx, e2.dy = 0, 0
            end
        end
    end
end

function Physics:checkCollision(e1, e2)
    return e1.x < e2.x + e2.width and
           e1.x + e1.width > e2.x and
           e1.y < e2.y + e2.height and
           e1.y + e1.height > e2.y
end

return Physics
