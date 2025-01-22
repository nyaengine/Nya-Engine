SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager:new()
    local sm = setmetatable({}, self)
    sm.currentScene = nil
    sm.scenes = {}
    return sm
end

function SceneManager:changeScene(scene)
    self.currentScene = scene
end

function SceneManager:addScene(scene)
    table.insert(self.scenes, scene)
end

function SceneManager:update(dt)

end

function SceneManager:draw()
    
end

return SceneManager