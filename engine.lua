local engine = {}
local SceneManager = require("lib/SceneManager")
local AudioEngine = require("lib/AudioEngine")
local ObjectLibrary = require("lib/ObjectLibrary")
local Camera = require("lib/Camera")

local objects = {}
local CollisionObjects = {}
local selectedObject = nil
local running = false
local isDragging = false

local sceneManager = SceneManager:new()
local camera = Camera:new(0, 0, 1)

function engine:load()

end

function engine:setcollisionobj()
	table.insert(CollisionObjects, selectedObject)
end

function engine:createnewobject()
	local newObject = ObjectLibrary:new(150, 100, 50, 50)
    table.insert(objects, newObject)
    table.insert(ObjectList, "Object " .. tostring(#objects)) -- Add only the new object to ObjectList
end

function engine:update(dt)
	-- Update all objects
 	if running then
        for _, obj in ipairs(objects) do
            obj:update(dt)
        end
    end

    -- Dragging logic
    if isDragging and selectedObject then
        local mouseX, mouseY = love.mouse.getPosition()
        selectedObject.x = mouseX / camera.scale - camera.x - selectedObject.width / 2
        selectedObject.y = mouseY / camera.scale - camera.y - selectedObject.height / 2
    end

    sceneManager:update(dt)

    if love.keyboard.isDown("w") then
        camera:move(0, -10)
    end

    if love.keyboard.isDown("s") then
        camera:move(0, 10)
    end

    if love.keyboard.isDown("d") then
        camera:move(10, 0)
    end

    if love.keyboard.isDown("a") then
        camera:move(-10, 0)
    end

    if love.keyboard.isDown("=") then
        camera:zoom(1.1)
    end

    if love.keyboard.isDown("-") then
        camera:zoom(0.9)
    end
end

function engine:mousepressed(x, y, button, istouch, presses)
	-- Check if an object is clicked
    local camX, camY = x / camera.scale + camera.x, y / camera.scale + camera.y
    for index, obj in ipairs(objects) do
        if obj:isClicked(camX, camY) then
            selectedObject = obj
            isDragging = true
                
            -- Update ObjectName label with the corresponding name from ObjectList
            ui:changetext(ObjectName, ObjectList[index])

            -- Deselect if clicked outside any object
        	selectedObject = nil
        	-- Reset the ObjectName label if no object is selected
        	ui:changetext(ObjectName, "ObjectName")

            return
        end
    end
end

return engine