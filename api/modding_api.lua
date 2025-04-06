local modding_api = {}

function modding_api.createObject(params)
    local newObject = GameObject:new(params)
    table.insert(objects, newObject)
    table.insert(ObjectList, newObject.name)
    return newObject
end

function modding_api.addScene(sceneName, sceneData)
    sceneManager:addScene(sceneName, sceneData)
    table.insert(SceneList, sceneName)
end

function modding_api.getObjects()
    return objects
end

return modding_api