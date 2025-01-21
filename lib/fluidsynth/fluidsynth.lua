local ffi = require("ffi")

ffi.cdef[[
    typedef void* fluid_settings_t;
    typedef void* fluid_synth_t;
    typedef void* fluid_audio_driver_t;

    fluid_settings_t* new_fluid_settings();
    fluid_synth_t* new_fluid_synth(fluid_settings_t* settings);
    fluid_audio_driver_t* new_fluid_audio_driver(fluid_settings_t* settings, fluid_synth_t* synth);
    void delete_fluid_audio_driver(fluid_audio_driver_t* driver);
    void delete_fluid_synth(fluid_synth_t* synth);
    void delete_fluid_settings(fluid_settings_t* settings);

    int fluid_synth_sfload(fluid_synth_t* synth, const char* filename, int reset_presets);
    int fluid_synth_noteon(fluid_synth_t* synth, int chan, int key, int vel);
    int fluid_synth_noteoff(fluid_synth_t* synth, int chan, int key);
]]

local fluidsynth = ffi.load("libfluidsynth-3")

local FluidSynth = {}
FluidSynth.__index = FluidSynth

function FluidSynth:new(soundfontPath)
    local settings = fluidsynth.new_fluid_settings()
    local synth = fluidsynth.new_fluid_synth(settings)
    local driver = fluidsynth.new_fluid_audio_driver(settings, synth)

    local instance = {
        settings = settings,
        synth = synth,
        driver = driver,
        soundfontPath = soundfontPath
    }

    setmetatable(instance, FluidSynth)

    -- Load the SoundFont
    if fluidsynth.fluid_synth_sfload(synth, soundfontPath, 1) == -1 then
        error("Failed to load SoundFont: " .. soundfontPath)
    end

    return instance
end

function FluidSynth:play(note, velocity, channel)
    channel = channel or 0
    fluidsynth.fluid_synth_noteon(self.synth, channel, note, velocity)
end

function FluidSynth:stop(note, channel)
    channel = channel or 0
    fluidsynth.fluid_synth_noteoff(self.synth, channel, note)
end

function FluidSynth:destroy()
    fluidsynth.delete_fluid_audio_driver(self.driver)
    fluidsynth.delete_fluid_synth(self.synth)
    fluidsynth.delete_fluid_settings(self.settings)
end

return FluidSynth
