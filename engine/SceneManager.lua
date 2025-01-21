SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager:new()
    local sm = setmetatable({}, self)
    sm.currentScene = nil
    return sm
end

function SceneManager:changeScene(scene)
    self.currentScene = scene
    self.currentScene:load()
end

function SceneManager:update(dt)
    if self.currentScene then
        self.currentScene:update(dt)
    end
end

function SceneManager:draw()
    if self.currentScene then
        self.currentScene:draw()
    end
end

return SceneManager