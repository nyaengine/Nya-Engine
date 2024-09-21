local AudioEngine = {}

function AudioEngine:init()
    self.sounds = {}
    self.music = nil
    self.musicVolume = 1.0
    self.soundVolume = 1.0
end

function AudioEngine:new()
    local instance = {}
    setmetatable(instance, { __index = AudioEngine })
    instance:init()
    return instance
end

function AudioEngine:loadSound(name, file)
    self.sounds[name] = love.audio.newSource(file, "static")
end

function AudioEngine:playSound(name)
    if self.sounds[name] then
        self.sounds[name]:play()
    end
end

function AudioEngine:stopSound(name)
    if self.sounds[name] then
        self.sounds[name]:stop()
    end
end

function AudioEngine:loadMusic(file)
    self.music = love.audio.newSource(file, "stream")
    self.music:setLooping(true)
    self.music:play()
end

function AudioEngine:playMusic()
    if self.music then
        self.music:play()
    end
end

function AudioEngine:stopMusic()
    if self.music then
        self.music:stop()
    end
end

function AudioEngine:setMusicVolume(volume)
    self.musicVolume = volume
    if self.music then
        self.music:setVolume(volume)
    end
end

function AudioEngine:setSoundVolume(volume)
    self.soundVolume = volume
    for _, sound in pairs(self.sounds) do
        sound:setVolume(volume)
    end
end

function AudioEngine:update(dt)
    -- Update music and sound volumes
    if self.music then
        self.music:setVolume(self.musicVolume)
    end
    for _, sound in pairs(self.sounds) do
        sound:setVolume(self.soundVolume)
    end
end

return AudioEngine