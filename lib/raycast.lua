local Raycast = {}

-- Check intersection of a ray with a line segment
function Raycast.rayToLine(rayOrigin, rayDir, lineStart, lineEnd)
    local dx = lineEnd.x - lineStart.x
    local dy = lineEnd.y - lineStart.y
    local det = -rayDir.x * dy + rayDir.y * dx

    if det == 0 then return nil end -- Parallel lines, no intersection

    local u = ((rayOrigin.x - lineStart.x) * dy - (rayOrigin.y - lineStart.y) * dx) / det
    local v = ((rayOrigin.x - lineStart.x) * rayDir.y - (rayOrigin.y - lineStart.y) * rayDir.x) / det

    if u >= 0 and v >= 0 and v <= 1 then
        return {x = rayOrigin.x + u * rayDir.x, y = rayOrigin.y + u * rayDir.y}
    end

    return nil
end

-- Check intersection of a ray with an axis-aligned bounding box (AABB)
function Raycast.rayToAABB(rayOrigin, rayDir, box)
    local tmin = (box.x - rayOrigin.x) / rayDir.x
    local tmax = (box.x + box.w - rayOrigin.x) / rayDir.x

    if tmin > tmax then tmin, tmax = tmax, tmin end

    local tymin = (box.y - rayOrigin.y) / rayDir.y
    local tymax = (box.y + box.h - rayOrigin.y) / rayDir.y

    if tymin > tymax then tymin, tymax = tymax, tymin end

    if tmin > tymax or tymin > tmax then return nil end

    tmin = math.max(tmin, tymin)
    tmax = math.min(tmax, tymax)

    if tmin < 0 then return nil end

    return {
        x = rayOrigin.x + tmin * rayDir.x,
        y = rayOrigin.y + tmin * rayDir.y
    }
end

return Raycast