-- engine/assets.lua

local Assets = {
    images = {},
    sounds = {},
    fonts = {}
}

function Assets:loadImage(name, path)
    self.images[name] = love.graphics.newImage(path)
end

function Assets:getImage(name)
    return self.images[name]
end

function Assets:loadSound(name, path)
    self.sounds[name] = love.audio.newSource(path, "static")
end

function Assets:getSound(name)
    return self.sounds[name]
end

-- Similar functions can be added for fonts and other assets
return Assets
