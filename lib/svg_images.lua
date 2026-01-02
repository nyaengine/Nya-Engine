local SVG = {}

local STEPS = 12

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function quadBezier(p0, p1, p2, t)
    local x = lerp(lerp(p0.x, p1.x, t), lerp(p1.x, p2.x, t), t)
    local y = lerp(lerp(p0.y, p1.y, t), lerp(p1.y, p2.y, t), t)
    return { x = x, y = y }
end

local function cubicBezier(p0, p1, p2, p3, t)
    local a = quadBezier(p0, p1, p2, t)
    local b = quadBezier(p1, p2, p3, t)
    return {
        x = lerp(a.x, b.x, t),
        y = lerp(a.y, b.y, t)
    }
end

function SVG.parsePath(d)
    local points = {}
    local cx, cy = 0, 0
    local sx, sy = 0, 0
    local pcx, pcy = 0, 0

    for cmd, args in d:gmatch("([MmLlHhVvCcQqTtZz])([^MmLlHhVvCcQqTtZz]*)") do
        local nums = {}
        for n in args:gmatch("-?%d+%.?%d*") do
            nums[#nums+1] = tonumber(n)
        end

        local rel = cmd:lower() == cmd
        cmd = cmd:upper()

        local i = 1
        local function nextXY()
            local x, y = nums[i], nums[i+1]
            i = i + 2
            if rel then
                x, y = cx + x, cy + y
            end
            return x, y
        end

        if cmd == "M" then
            cx, cy = nextXY()
            sx, sy = cx, cy
            table.insert(points, {cx, cy})

        elseif cmd == "L" then
            while i <= #nums do
                cx, cy = nextXY()
                table.insert(points, {cx, cy})
            end

        elseif cmd == "H" then
            for _, x in ipairs(nums) do
                if rel then x = cx + x end
                cx = x
                table.insert(points, {cx, cy})
            end

        elseif cmd == "V" then
            for _, y in ipairs(nums) do
                if rel then y = cy + y end
                cy = y
                table.insert(points, {cx, cy})
            end

        elseif cmd == "Q" then
            while i <= #nums do
                local x1, y1 = nextXY()
                local x2, y2 = nextXY()
                local p0 = {x=cx,y=cy}
                local p1 = {x=x1,y=y1}
                local p2 = {x=x2,y=y2}
                for t = 0, 1, 1/STEPS do
                    local p = quadBezier(p0, p1, p2, t)
                    table.insert(points, {p.x, p.y})
                end
                cx, cy = x2, y2
                pcx, pcy = x1, y1
            end

        elseif cmd == "C" then
            while i <= #nums do
                local x1,y1 = nextXY()
                local x2,y2 = nextXY()
                local x3,y3 = nextXY()
                local p0={x=cx,y=cy}
                local p1={x=x1,y=y1}
                local p2={x=x2,y=y2}
                local p3={x=x3,y=y3}
                for t=0,1,1/STEPS do
                    local p = cubicBezier(p0,p1,p2,p3,t)
                    table.insert(points,{p.x,p.y})
                end
                cx, cy = x3, y3
                pcx, pcy = x2, y2
            end

        elseif cmd == "T" then
            while i <= #nums do
                local x2,y2 = nextXY()
                local x1 = 2*cx - pcx
                local y1 = 2*cy - pcy
                local p0={x=cx,y=cy}
                local p1={x=x1,y=y1}
                local p2={x=x2,y=y2}
                for t=0,1,1/STEPS do
                    local p = quadBezier(p0,p1,p2,t)
                    table.insert(points,{p.x,p.y})
                end
                cx, cy = x2, y2
                pcx, pcy = x1, y1
            end

        elseif cmd == "Z" then
            table.insert(points, {sx, sy})
            cx, cy = sx, sy
        end
    end

    return points
end

function SVG.pathToMesh(d)
    local pts = SVG.parsePath(d)
    if #pts < 3 then return nil end

    local triangles = love.math.triangulate(pts)
    local verts = {}

    for _, tri in ipairs(triangles) do
        for _, p in ipairs(tri) do
            table.insert(verts, {
                p[1], p[2],
                0, 0,
                1, 1, 1, 1
            })
        end
    end

    return love.graphics.newMesh(verts, "triangles")
end

function SVG.load(filename)
    local data = love.filesystem.read(filename)
    local meshes = {}

    for d, fill in data:gmatch('<path[^>]-d="([^"]+)"[^>]-fill="([^"]+)"') do
        local mesh = SVG.pathToMesh(d)
        if mesh then
            table.insert(meshes, { mesh = mesh, fill = fill })
        end
    end

    return meshes
end

function SVG.parseColor(fill)
    if fill == "none" then return 1,1,1,1 end
    local r,g,b = fill:match("#(%x%x)(%x%x)(%x%x)")
    if r then
        return tonumber(r,16)/255,
               tonumber(g,16)/255,
               tonumber(b,16)/255,
               1
    end
    return 1,1,1,1
end

function SVG.draw(svg)
    if not svg then return end

    for _, obj in ipairs(svg) do
        local r,g,b,a = SVG.parseColor(obj.fill)
        love.graphics.setColor(r,g,b,a)
        love.graphics.draw(obj.mesh)
    end

    love.graphics.setColor(1,1,1,1)
end

return SVG
