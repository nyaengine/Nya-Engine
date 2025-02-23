local SVG = {}

function SVG.parsePath(path)
    local vertices = {}  -- Stores points for the mesh
    local lastX, lastY = 0, 0
    local startX, startY = 0, 0  -- Track starting position for 'Z' command

    local function addVertex(x, y)
        table.insert(vertices, {x, y})
        lastX, lastY = x, y
    end

    local function cubicBezier(p0, p1, p2, p3, steps)
        local points = {}
        for t = 0, 1, 1 / steps do
            local x = (1 - t)^3 * p0.x + 3 * (1 - t)^2 * t * p1.x + 3 * (1 - t) * t^2 * p2.x + t^3 * p3.x
            local y = (1 - t)^3 * p0.y + 3 * (1 - t)^2 * t * p1.y + 3 * (1 - t) * t^2 * p2.y + t^3 * p3.y
            table.insert(points, {x, y})
        end
        return points
    end

    local function quadraticBezier(p0, p1, p2, steps)
        local points = {}
        for t = 0, 1, 1 / steps do
            local x = (1 - t)^2 * p0.x + 2 * (1 - t) * t * p1.x + t^2 * p2.x
            local y = (1 - t)^2 * p0.y + 2 * (1 - t) * t * p1.y + t^2 * p2.y
            table.insert(points, {x, y})
        end
        return points
    end

    -- Regex to extract SVG path commands and numbers
    for command, args in path:gmatch("([MLHVCSQTZ])([^MLHVCSQTZ]*)") do
        local numbers = {}
        for num in args:gmatch("-?%d+%.?%d*") do
            table.insert(numbers, tonumber(num))
        end

        if command == "M" then  -- Move To
            lastX, lastY = numbers[1], numbers[2]
            startX, startY = lastX, lastY
            addVertex(lastX, lastY)
        elseif command == "L" then  -- Line To
            for i = 1, #numbers, 2 do
                addVertex(numbers[i], numbers[i + 1])
            end
        elseif command == "H" then  -- Horizontal Line
            for _, x in ipairs(numbers) do
                addVertex(x, lastY)
            end
        elseif command == "V" then  -- Vertical Line
            for _, y in ipairs(numbers) do
                addVertex(lastX, y)
            end
        elseif command == "C" then  -- Cubic Bezier Curve
            for i = 1, #numbers, 6 do
                local p0 = {x = lastX, y = lastY}
                local p1 = {x = numbers[i], y = numbers[i + 1]}
                local p2 = {x = numbers[i + 2], y = numbers[i + 3]}
                local p3 = {x = numbers[i + 4], y = numbers[i + 5]}
                local curvePoints = cubicBezier(p0, p1, p2, p3, 10)  -- 10 interpolation steps
                for _, p in ipairs(curvePoints) do
                    addVertex(p.x, p.y)
                end
            end
        elseif command == "Q" then  -- Quadratic Bezier Curve
            for i = 1, #numbers, 4 do
                local p0 = {x = lastX, y = lastY}
                local p1 = {x = numbers[i], y = numbers[i + 1]}
                local p2 = {x = numbers[i + 2], y = numbers[i + 3]}
                local curvePoints = quadraticBezier(p0, p1, p2, 10)
                for _, p in ipairs(curvePoints) do
                    addVertex(p.x, p.y)
                end
            end
        elseif command == "Z" then  -- Close Path
            addVertex(startX, startY)
        end
    end

    return vertices
end

-- Function to convert path data into a drawable mesh
function SVG.pathToMesh(path)
    local vertices = SVG.parsePath(path)
    if #vertices < 3 then
        return nil  -- Mesh requires at least 3 points
    end
    return love.graphics.newMesh(vertices, "fan")
end

-- Function to load an SVG file and extract paths
function SVG.load(filename)
    local file = love.filesystem.read(filename)
    if not file then
        error("Failed to load SVG file: " .. filename)
    end
    
    local paths = {}
    for path in string.gmatch(file, '<path[^>]*d="([^"]+)"') do
        local mesh = SVG.pathToMesh(path)
        if mesh then
            table.insert(paths, mesh)
        end
    end

    return paths
end

-- Function to draw all loaded SVG meshes
function SVG.draw(meshes)
    for _, mesh in ipairs(meshes) do
        love.graphics.draw(mesh)
    end
end

return SVG
