local Scene = {}
Scene.__index = Scene

function Scene:new(world)
    local scene = setmetatable({}, Scene)
    scene.objects = {}
    scene.world = world  -- Reference to the physics world
    return scene
end

-- Add an object to the scene
function Scene:addObject(object)
    table.insert(self.objects, object)
end

-- Remove an object from the scene
function Scene:removeObject(object)
    for i, obj in ipairs(self.objects) do
        if obj == object then
            obj:destroy()  -- Destroy the physics body if it's a physics object
            table.remove(self.objects, i)
            break
        end
    end
end

-- Update all objects in the scene
function Scene:update(dt)
    for _, obj in ipairs(self.objects) do
        if obj.update then
            obj:update(dt)
        end
    end
end

-- Render all objects in the scene
function Scene:render()
    for _, obj in ipairs(self.objects) do
        if obj.render then
            obj:render()
        end
    end
end

return Scene
