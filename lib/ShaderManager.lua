local ShaderManager = {}

ShaderManager.enabled = false
ShaderManager.shaders = {}
ShaderManager.active = nil
ShaderManager.canvas = nil

local function makeShader(code)
    if not love or not love.graphics then return nil end
    local ok, sh = pcall(love.graphics.newShader, code)
    if ok then return sh end
    return nil
end

function ShaderManager.init()
    -- create default shaders
    ShaderManager.shaders = {}

    local grayscale = [[
        extern number intensity = 1.0;
        vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
        {
            vec4 c = Texel(tex, uv);
            float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));
            return vec4(mix(c.rgb, vec3(g), intensity), c.a) * color;
        }
    ]]

    local invert = [[
        vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
        {
            vec4 c = Texel(tex, uv);
            c.rgb = 1.0 - c.rgb;
            return c * color;
        }
    ]]

    local sepia = [[
        vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px)
        {
            vec4 c = Texel(tex, uv);
            float r = dot(c.rgb, vec3(0.393, 0.769, 0.189));
            float g = dot(c.rgb, vec3(0.349, 0.686, 0.168));
            float b = dot(c.rgb, vec3(0.272, 0.534, 0.131));
            return vec4(r, g, b, c.a) * color;
        }
    ]]

    ShaderManager.shaders["none"] = nil
    ShaderManager.shaders["grayscale"] = makeShader(grayscale)
    ShaderManager.shaders["invert"] = makeShader(invert)
    ShaderManager.shaders["sepia"] = makeShader(sepia)

    -- create canvas sized to window
    if love and love.graphics then
        ShaderManager.canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    end
end

function ShaderManager.getCanvas()
    if not ShaderManager.canvas and love and love.graphics then
        ShaderManager.canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    end
    return ShaderManager.canvas
end

function ShaderManager.setActive(name)
    if name == "none" or not name then
        ShaderManager.active = nil
        return
    end
    ShaderManager.active = ShaderManager.shaders[name]
end

function ShaderManager.toggle()
    ShaderManager.enabled = not ShaderManager.enabled
end

function ShaderManager.enable()
    ShaderManager.enabled = true
end

function ShaderManager.disable()
    ShaderManager.enabled = false
end

function ShaderManager.list()
    local out = {}
    for k,_ in pairs(ShaderManager.shaders) do table.insert(out, k) end
    return out
end

function ShaderManager.cycle()
    local keys = {}
    for k,_ in pairs(ShaderManager.shaders) do table.insert(keys, k) end
    table.sort(keys)
    if not ShaderManager.active then
        -- choose first non-none if exists
        if #keys > 1 then ShaderManager.setActive(keys[2]) end
        return
    end
    local currentName
    for name, sh in pairs(ShaderManager.shaders) do
        if sh == ShaderManager.active then currentName = name; break end
    end
    local idx = 1
    for i,n in ipairs(keys) do if n == currentName then idx = i; break end end
    local nextIdx = (idx % #keys) + 1
    local nextName = keys[nextIdx]
    if nextName == "none" then ShaderManager.setActive(nil) else ShaderManager.setActive(nextName) end
end

function ShaderManager.apply(canvas)
    if not ShaderManager.enabled then
        -- just draw canvas
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(canvas, 0, 0)
        return
    end
    local sh = ShaderManager.active
    if sh then
        love.graphics.setShader(sh)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(canvas, 0, 0)
        love.graphics.setShader()
    else
        -- enabled but no active shader -> draw canvas normally
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(canvas, 0, 0)
    end
end

return ShaderManager
