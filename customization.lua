local customization = {}

-- Define colors as a table of named color presets
customization.colors = {
    background = {0.1, 0.1, 0.1}, -- Dark grey
    text = {1, 1, 1},            -- White
    primary = {1, 0.4, 0.7},
    topbar = {1, 0.4, 0.7, 0.5},
    secondary = {0.8, 0.3, 0.6},
    textbox = {1, 1, 1},      
    success = {0.4, 0.8, 0.4},   -- Green
    warning = {0.9, 0.7, 0.2},   -- Yellow
    error = {0.9, 0.2, 0.2},     -- Bright red
}

-- Function to get a color by name
function customization.getColor(name)
    return customization.colors[name] or {1, 1, 1} -- Default to white if the color is not found
end

-- Define fonts as a table of named fonts
customization.fonts = {
    Poppins = love.graphics.newFont("assets/fonts/Poppins-Regular.ttf", 15),
    ["Noto Sans"] = love.graphics.newFont("assets/fonts/Noto Sans/NotoSans-Regular.ttf", 15),
}

-- Function to get a font by name
function customization.getFont(name)
    return customization.fonts[name] or love.graphics.getFont() -- Default to LOVE's current font if not found
end

return customization
