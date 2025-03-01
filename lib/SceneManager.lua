-- SceneManager.lua

SceneManager = {}
SceneManager.__index = SceneManager

-- Constructor
function SceneManager:new()
    local instance = {
        scenes = {},
        currentScene = nil,
        SceneObj = {}
    }
    setmetatable(instance, SceneManager)
    return instance
end

-- Add a new scene
function SceneManager:addScene(name, scene)
    self.scenes[name] = scene
end

-- Remove a scene
function SceneManager:removeScene(name)
    if self.scenes[name] then
        if self.currentScene == self.scenes[name] then
            self.currentScene = nil
        end
        self.scenes[name] = nil
    else
        error("Scene '" .. name .. "' does not exist!")
    end
end

function SceneManager:addObject(name)
    table.insert(self.SceneObj, name)
end

-- Switch to a specific scene
function SceneManager:changeScene(name)
    if self.scenes[name] then
        if self.currentScene and self.currentScene.exit then
            self.currentScene:exit()
        end
        self.currentScene = self.scenes[name]
        if self.currentScene.enter then
            self.currentScene:enter()
        end
    else
        error("Scene '" .. name .. "' does not exist!")
    end
end

-- Update the current scene
function SceneManager:update(dt)
    if self.currentScene and self.currentScene.update then
        self.currentScene:update(dt)
    end
end

-- Draw the current scene
function SceneManager:draw()
    if self.currentScene and self.currentScene.draw then
        self.currentScene:draw()
    end
end

-- Input handling for the current scene
function SceneManager:keypressed(key)
    if self.currentScene and self.currentScene.keypressed then
        self.currentScene:keypressed(key)
    end
end

function SceneManager:keyreleased(key)
    if self.currentScene and self.currentScene.keyreleased then
        self.currentScene:keyreleased(key)
    end
end

function SceneManager:mousepressed(x, y, button)
    if self.currentScene and self.currentScene.mousepressed then
        self.currentScene:mousepressed(x, y, button)
    end
end

function SceneManager:mousereleased(x, y, button)
    if self.currentScene and self.currentScene.mousereleased then
        self.currentScene:mousereleased(x, y, button)
    end
end

return SceneManager
