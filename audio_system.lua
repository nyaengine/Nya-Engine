local AudioSystem = {}
AudioSystem.__index = AudioSystem

function AudioSystem:new()
    local audio = setmetatable({}, AudioSystem)
    audio.sounds = {}
    audio.listenerX, audio.listenerY = 0, 0
    return audio
end

function AudioSystem:setListenerPosition(x, y)
    self.listenerX, self.listenerY = x, y
    love.audio.setPosition(x, y, 0)
end

-- Add a sound source with spatial effects, if mono
function AudioSystem:addSound(file, x, y, loop)
    local soundData = love.audio.newSource(file, "static")
    soundData:setLooping(loop or false)

    -- Only set position if the sound is mono (has 1 channel)
    if soundData:getChannelCount() == 1 then
        soundData:setPosition(x, y, 0)
        soundData:setAttenuationDistances(100, 300)
        soundData:setRelative(false)
    else
        print("Warning: Sound file " .. file .. " is not mono. Spatial effects will not be applied.")
    end

    table.insert(self.sounds, { source = soundData, x = x, y = y })
    return soundData
end

function AudioSystem:playSound(source)
    source:play()
end

function AudioSystem:setSoundPosition(soundData, x, y)
    if soundData:getChannelCount() == 1 then
        soundData:setPosition(x, y, 0)
    end
end

function AudioSystem:stopAll()
    for _, sound in ipairs(self.sounds) do
        sound.source:stop()
    end
end

return AudioSystem
