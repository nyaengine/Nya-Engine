-- raycast.lua

local Raycast = {}
Raycast.__index = Raycast

-- Create a new ray object
function Raycast.new(x, y, dx, dy)
    local self = setmetatable({}, Raycast)
    self.x = x    -- origin x
    self.y = y    -- origin y
    self.dx = dx  -- direction x
    self.dy = dy  -- direction y
    return self
end

-- Utility function to detect line intersection
local function lineIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
    local denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if denominator == 0 then return nil end  -- Lines are parallel or coincident

    local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator
    local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denominator

    if t >= 0 and t <= 1 and u >= 0 then
        return x1 + t * (x2 - x1), y1 + t * (y2 - y1)  -- Return intersection point
    end

    return nil  -- No intersection
end

-- Casts a ray to find intersections with lines
function Raycast:castLine(x1, y1, x2, y2)
    local ix, iy = lineIntersection(self.x, self.y, self.x + self.dx, self.y + self.dy, x1, y1, x2, y2)
    if ix and iy then
        local distance = math.sqrt((ix - self.x)^2 + (iy - self.y)^2)
        return { x = ix, y = iy, distance = distance }
    end
    return nil  -- No intersection
end

-- Cast ray to find the closest intersection with multiple lines
function Raycast:castToLines(lines)
    local closestHit = nil
    for _, line in ipairs(lines) do
        local hit = self:castLine(line[1], line[2], line[3], line[4])
        if hit and (not closestHit or hit.distance < closestHit.distance) then
            closestHit = hit
        end
    end
    return closestHit
end

return Raycast
