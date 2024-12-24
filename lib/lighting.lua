local Lighting = {}

function Lighting:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.lights = {}
    obj.canvas = love.graphics.newCanvas()
    obj.shader = love.graphics.newShader([[
        extern vec2 light_position;
        extern number light_radius;
        extern vec3 light_color;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec2 diff = screen_coords - light_position;
            float dist = length(diff);
            float intensity = max(0.0, 1.0 - dist / light_radius);

            // Add light rays effect
            float angle = atan(diff.y, diff.x);
            float ray_factor = sin(angle * 10.0) * 0.1; // Adjust frequency and strength here
            intensity += ray_factor * intensity;

            return vec4(light_color * intensity, intensity);
        }
    ]])

    return obj
end

function Lighting:addLight(x, y, radius, color)
    table.insert(self.lights, {
        x = x,
        y = y,
        radius = radius,
        color = color or {1, 1, 1}
    })
end

function Lighting:clearLights()
    self.lights = {}
end

function Lighting:render()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.push()
    love.graphics.origin()

    for _, light in ipairs(self.lights) do
        self.shader:send("light_position", {light.x, light.y})
        self.shader:send("light_radius", light.radius)
        self.shader:send("light_color", light.color)

        love.graphics.setShader(self.shader)
        love.graphics.setBlendMode("add")
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    love.graphics.pop()
    love.graphics.setBlendMode("alpha")
    love.graphics.setShader()
    love.graphics.setCanvas()
end

function Lighting:draw(drawSceneCallback)
    love.graphics.setColor(1, 1, 1, 1)
    drawSceneCallback()

    love.graphics.setBlendMode("add")
    love.graphics.draw(self.canvas, 0, 0)
    love.graphics.setBlendMode("alpha")
end

return Lighting
