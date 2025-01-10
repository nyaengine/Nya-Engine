local Tilemap = {}
Tilemap.__index = Tilemap

-- Creates a new Tilemap instance
function Tilemap.new(tilesetPath, tileWidth, tileHeight, mapData)
    local self = setmetatable({}, Tilemap)

    -- Load tileset image
    self.tileset = love.graphics.newImage(tilesetPath)
    self.tileWidth = tileWidth
    self.tileHeight = tileHeight
    self.mapData = mapData

    -- Calculate tileset grid dimensions
    self.tilesetWidth = self.tileset:getWidth()
    self.tilesetHeight = self.tileset:getHeight()

    self.columns = math.floor(self.tilesetWidth / tileWidth)
    self.rows = math.floor(self.tilesetHeight / tileHeight)

    -- Generate quads for each tile in the tileset
    self.quads = {}
    for y = 0, self.rows - 1 do
        for x = 0, self.columns - 1 do
            local quad = love.graphics.newQuad(
                x * tileWidth, y * tileHeight,
                tileWidth, tileHeight,
                self.tilesetWidth, self.tilesetHeight
            )
            table.insert(self.quads, quad)
        end
    end

    return self
end

-- Draw the tilemap
function Tilemap:draw(offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0

    for row = 1, #self.mapData do
        for col = 1, #self.mapData[row] do
            local tileIndex = self.mapData[row][col]

            if tileIndex > 0 then -- Only draw non-empty tiles
                local quad = self.quads[tileIndex]
                local x = (col - 1) * self.tileWidth + offsetX
                local y = (row - 1) * self.tileHeight + offsetY

                love.graphics.draw(self.tileset, quad, x, y)
            end
        end
    end
end

-- Generate map data to cover the entire screen
function Tilemap:generateFullScreenMap(screenWidth, screenHeight)
    local rows = math.ceil(screenHeight / self.tileHeight)
    local cols = math.ceil(screenWidth / self.tileWidth)

    self.mapData = {}
    for row = 1, rows do
        self.mapData[row] = {}
        for col = 1, cols do
            -- Randomize tile indices (you can replace this with meaningful patterns)
            self.mapData[row][col] = math.random(1, #self.quads)
        end
    end
end

return Tilemap
