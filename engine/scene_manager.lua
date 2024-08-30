-- engine/scene_manager.lua

local SceneManager = {
    currentScene = nil,
    scenes = {}
}

function SceneManager:addScene(name, scene)
    self.scenes[name] = scene
end

function SceneManager:switchTo(sceneName)
    if self.scenes[sceneName] then
        self.currentScene = self.scenes[sceneName]
        self.currentScene:load()
    else
        print("Scene not found: " .. sceneName)
    end
end

function SceneManager:update(dt)
    if self.currentScene and self.currentScene.update then
        self.currentScene:update(dt)
    end
end

function SceneManager:draw()
    if self.currentScene and self.currentScene.draw then
        self.currentScene:draw()
    end
end

return SceneManager
