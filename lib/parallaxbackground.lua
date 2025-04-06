local ParallaxBackground = {
    layers = {}
}

function ParallaxBackground:new()
    local obj = { layers = {} }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function ParallaxBackground:addLayer(imagePath, speed)
    local image = love.graphics.newImage(imagePath)
    table.insert(self.layers, { image = image, speed = speed, offsetX = 0 })
end

function ParallaxBackground:update(dt)
    for _, layer in ipairs(self.layers) do
        layer.offsetX = (layer.offsetX + layer.speed * dt) % layer.image:getWidth()
    end
end

function ParallaxBackground:draw()
    for _, layer in ipairs(self.layers) do
        local imgWidth = layer.image:getWidth()
        local imgHeight = layer.image:getHeight()
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()

        -- Draw the layer twice to create a seamless scrolling effect
        for x = -layer.offsetX, screenWidth, imgWidth do
            love.graphics.draw(layer.image, x, 0, 0, screenWidth / imgWidth, screenHeight / imgHeight)
        end
    end
end

return ParallaxBackground