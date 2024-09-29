-- scriptable_object.lua
ScriptableObject = {}
ScriptableObject.__index = ScriptableObject

function ScriptableObject:new(scriptPath)
    local obj = setmetatable({}, ScriptableObject)
    obj.scriptPath = scriptPath
    obj.scriptEnv = setmetatable({}, { __index = _G })
    obj.scriptFunc = nil
    return obj
end

function ScriptableObject:load()
    local chunk, err = loadfile(self.scriptPath)
    if not chunk then
        error(err)
    end
    setfenv(chunk, self.scriptEnv)
    self.scriptFunc = chunk()
end

function ScriptableObject:update(dt)
    if self.scriptFunc then
        self.scriptFunc(dt)
    end
end

return ScriptableObject