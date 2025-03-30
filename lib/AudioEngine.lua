local AudioEngine = {}

AudioEngine.sounds = {}

-- Function to load sounds
function AudioEngine.loadSound(name, path, isSpatial)
    local sound = love.audio.newSource(path, "static")
    
    -- Add spatial properties if necessary
    if isSpatial then
        sound:setPosition(0, 0, 0)  -- Default position at origin
        sound:setDistanceModel("linear")  -- Set distance model
        sound:setAttenuationDistances(1, 100)  -- Adjust attenuation range
    end
    
    AudioEngine.sounds[name] = {
        source = sound,
        isSpatial = isSpatial
    }
end

-- Function to play sounds
function AudioEngine.playSound(name, x, y, z)
    local soundData = AudioEngine.sounds[name]
    if soundData then
        local sound = soundData.source
        
        -- If it's a spatial sound, update its position
        if soundData.isSpatial then
            sound:setPosition(x, y, z)
        end
        
        sound:play()
    else
        print("Sound not found: " .. name)
    end
end

-- Function to stop a sound
function AudioEngine.stopSound(name)
    local soundData = AudioEngine.sounds[name]
    if soundData then
        soundData.source:stop()
    else
        print("Sound not found: " .. name)
    end
end

-- Function to set the listener's position (for spatial audio)
function AudioEngine.setListenerPosition(x, y, z)
    love.audio.setPosition(x, y, z)
end

-- Function to pause all sounds
function AudioEngine.pauseAll()
    for name, soundData in pairs(AudioEngine.sounds) do
        soundData.source:pause()
    end
end

-- Function to resume all sounds
function AudioEngine.resumeAll()
    for name, soundData in pairs(AudioEngine.sounds) do
        soundData.source:play()
    end
end

-- Function to set volume for a specific sound
function AudioEngine.setVolume(name, volume)
    local soundData = AudioEngine.sounds[name]
    if soundData then
        soundData.source:setVolume(volume)
    else
        print("Sound not found: " .. name)
    end
end

-- Function to set global volume for all sounds
function AudioEngine.setGlobalVolume(volume)
    for _, soundData in pairs(AudioEngine.sounds) do
        soundData.source:setVolume(volume)
    end
end

return AudioEngine
