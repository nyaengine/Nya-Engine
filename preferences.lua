local preferences = {}

-- Function to load a JSON file and parse it into a Lua table
function loadJsonFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        return nil, "Could not open file: " .. filePath
    end

    local content = file:read("*a")
    file:close()
    return dkjson.decode(content)
end

-- Function to load a theme
function loadTheme(themeName)
    local themeData, err = loadJsonFile("preferences/" .. themeName .. ".json")
    if not themeData then
        error("Error loading theme: " .. err)
    end

    -- Update preferences with the new theme data
    preferences.button = themeData.button
    preferences.label = themeData.label
    preferences.topbar = themeData.topbar
    preferences.textbox = themeData.textbox
    preferences.windows = themeData.windows
    preferences.general = themeData.general
    preferences.dropdown = themeData.dropdown
end

-- Load the initial theme
loadTheme(selectedTheme)  -- Default theme

-- Load the fonts JSON file
local fontsData, err = loadJsonFile("preferences/fonts.json")
if not fontsData then
    error("Error loading fonts: " .. err)
end

-- Define fonts from fonts JSON
preferences.fonts = {}
for fontName, fontData in pairs(fontsData) do
    preferences.fonts[fontName] = love.graphics.newFont(fontData[1], 15)  -- Assuming size 15 by default
end

-- Function to get a color by name from the theme
function preferences.getColor(component, colorType)
    local componentData = preferences[component]
    if componentData and componentData[colorType] then
        return componentData[colorType]
    end
    return {1, 1, 1}  -- Default to white if the color is not found
end

-- Function to get a font by name
function preferences.getFont(name)
    return preferences.fonts[name] or love.graphics.getFont()  -- Default to LOVE's current font if not found
end

-- Function to change the theme dynamically
function preferences.setTheme(themeName)
    loadTheme(themeName)
end

return preferences