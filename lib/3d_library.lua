local love3d = {}

-- Helper function to create a perspective projection matrix
function love3d.perspective(fov, aspect, near, far)
    local f = 1 / math.tan(fov / 2)
    return {
        {f / aspect, 0, 0, 0},
        {0, f, 0, 0},
        {0, 0, (far + near) / (near - far), (2 * far * near) / (near - far)},
        {0, 0, -1, 0},
    }
end

-- Multiply a matrix by a vector
local function multiplyMatrixVector(matrix, vector)
    local result = {}
    for i = 1, 4 do
        result[i] = 0
        for j = 1, 4 do
            result[i] = result[i] + matrix[i][j] * vector[j]
        end
    end
    return result
end

-- Transform a 3D point into 2D screen space
function love3d.project(point, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    local worldPos = multiplyMatrixVector(viewMatrix, {point.x, point.y, point.z, 1})
    local clipSpace = multiplyMatrixVector(projectionMatrix, worldPos)

    local w = clipSpace[4]
    if w == 0 then w = 0.0001 end -- Prevent division by zero

    local normalized = {
        clipSpace[1] / w,
        clipSpace[2] / w,
        clipSpace[3] / w
    }

    local x = (normalized[1] * 0.5 + 0.5) * screenWidth
    local y = (1 - (normalized[2] * 0.5 + 0.5)) * screenHeight

    return x, y
end

-- Draw a line between two 3D points
function love3d.drawLine(p1, p2, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    local x1, y1 = love3d.project(p1, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    local x2, y2 = love3d.project(p2, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    love.graphics.line(x1, y1, x2, y2)
end

-- Draw a filled triangle between three 3D points
function love3d.drawTriangle(p1, p2, p3, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    local x1, y1 = love3d.project(p1, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    local x2, y2 = love3d.project(p2, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    local x3, y3 = love3d.project(p3, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
end

function love3d.loadMesh(filePath)
    local mesh = { vertices = {}, faces = {} }
    for line in love.filesystem.lines(filePath) do
        local prefix, rest = line:match("^(%S+)%s+(.*)")
        if prefix == "v" then
            local x, y, z = rest:match("(%S+)%s+(%S+)%s+(%S+)")
            table.insert(mesh.vertices, { x = tonumber(x), y = tonumber(y), z = tonumber(z) })
        elseif prefix == "f" then
            local indices = {}
            for index in rest:gmatch("%d+") do
                table.insert(indices, tonumber(index))
            end
            -- Validate indices
            local isValid = true
            for _, index in ipairs(indices) do
                if not mesh.vertices[index] then
                    isValid = false
                    break
                end
            end
            -- Triangulate and add valid faces
            if isValid and #indices >= 3 then
                for i = 2, #indices - 1 do
                    table.insert(mesh.faces, { indices[1], indices[i], indices[i + 1] })
                end
            end
        end
    end
    return mesh
end

-- Draw a mesh
function love3d.drawMesh(mesh, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    for _, face in ipairs(mesh.faces) do
        local p1 = mesh.vertices[face[1]]
        local p2 = mesh.vertices[face[2]]
        local p3 = mesh.vertices[face[3]]
        love3d.drawTriangle(p1, p2, p3, viewMatrix, projectionMatrix, screenWidth, screenHeight)
    end
end

return love3d
