local SVG = {}

-- Function to parse an SVG path and convert it to mesh-friendly data
function SVG.parsePath(path)
    local vertices = {}  -- Stores points for the mesh
    local lastX, lastY = 0, 0
    local startX, startY = 0, 0  -- Track starting position for 'Z' command
    local prevCtrlX, prevCtrlY = 0, 0  -- Control points for smooth curves
    local isRelative = false  -- Track relative commands

    local function addVertex(x, y)
        table.insert(vertices, {x, y})
        lastX, lastY = x, y
    end

    -- Function to handle absolute vs relative positioning
    local function getCoord(x, y)
        if isRelative then
            return lastX + x, lastY + y
        else
            return x, y
        end
    end

    -- Bezier Curve Interpolation
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
    for command, args in path:gmatch("([mMlLhHvVcCsSqQtTzZ])([^mMlLhHvVcCsSqQtTzZ]*)") do
        local numbers = {}
        for num in args:gmatch("-?%d+%.?%d*") do
            table.insert(numbers, tonumber(num))
        end

        isRelative = command:lower() == command  -- If lowercase, it's a relative command
        command = command:upper()  -- Normalize to uppercase for easier processing

        if command == "M" then  -- Move To
            lastX, lastY = getCoord(numbers[1], numbers[2])
            startX, startY = lastX, lastY
            addVertex(lastX, lastY)
        elseif command == "L" then  -- Line To
            for i = 1, #numbers, 2 do
                addVertex(getCoord(numbers[i], numbers[i + 1]))
            end
        elseif command == "H" then  -- Horizontal Line
            for _, x in ipairs(numbers) do
                addVertex(getCoord(x, 0))
            end
        elseif command == "V" then  -- Vertical Line
            for _, y in ipairs(numbers) do
                addVertex(getCoord(0, y))
            end
        elseif command == "C" then  -- Cubic Bezier Curve
            for i = 1, #numbers, 6 do
                local p0 = {x = lastX, y = lastY}
                local p1 = {x = getCoord(numbers[i], numbers[i + 1])}
                local p2 = {x = getCoord(numbers[i + 2], numbers[i + 3])}
                local p3 = {x = getCoord(numbers[i + 4], numbers[i + 5])}
                prevCtrlX, prevCtrlY = p2.x, p2.y
                local curvePoints = cubicBezier(p0, p1, p2, p3, 10)
                for _, p in ipairs(curvePoints) do
                    addVertex(p.x, p.y)
                end
            end
        elseif command == "Q" then  -- Quadratic Bezier Curve
            for i = 1, #numbers, 4 do
                local p0 = {x = lastX, y = lastY}
                local p1 = {x = getCoord(numbers[i], numbers[i + 1])}
                local p2 = {x = getCoord(numbers[i + 2], numbers[i + 3])}
                prevCtrlX, prevCtrlY = p1.x, p1.y
                local curvePoints = quadraticBezier(p0, p1, p2, 10)
                for _, p in ipairs(curvePoints) do
                    addVertex(p.x, p.y)
                end
            end
        elseif command == "T" then  -- Smooth Quadratic Curve
            for i = 1, #numbers, 2 do
                local p0 = {x = lastX, y = lastY}
                local p1 = {x = 2 * lastX - prevCtrlX, y = 2 * lastY - prevCtrlY}  -- Reflection
                local p2 = {x = getCoord(numbers[i], numbers[i + 1])}
                prevCtrlX, prevCtrlY = p1.x, p1.y
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
    for path, style in file:gmatch('<path[^>]*d="([^"]+)"[^>]*style="([^"]-)"') do
        local mesh = SVG.pathToMesh(path)
        if mesh then
            table.insert(paths, {mesh = mesh, style = style})
        end
    end

    return paths
end

-- Function to parse SVG color (for fills and strokes)
function SVG.parseColor(style)
    local color = {1, 1, 1, 1}  -- Default to white
    local r, g, b, a = style:match("fill:rgb%((%d+),(%d+),(%d+)%)")
    if r and g and b then
        color = {tonumber(r) / 255, tonumber(g) / 255, tonumber(b) / 255, 1}
    end
    return color
end

-- Function to draw all loaded SVG meshes
function SVG.draw(svgObjects)
    for _, obj in ipairs(svgObjects) do
        love.graphics.setColor(SVG.parseColor(obj.style))
        love.graphics.draw(obj.mesh)
    end
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color
end

return SVG
