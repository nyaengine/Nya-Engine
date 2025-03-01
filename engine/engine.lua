local engine = {}

--Game objects
selectedObject = nil
running = false
local isDragging = false
scaling = false
sceneManager = SceneManager:new()
local camera = Camera:new(0, 0, 1)
local dragOffsetX = 0
local dragOffsetY = 0

function engine:update(dt)
    -- Update all objects
    if running then
        for _, obj in ipairs(objects) do
            obj:update(dt)
        end
    end

    -- Dragging logic
    if isDragging and selectedObject and not scaling then
        local mouseX, mouseY = love.mouse.getPosition()
        local camX, camY = mouseX / camera.scale + camera.x, mouseY / camera.scale + camera.y
        selectedObject.x = camX - dragOffsetX
        selectedObject.y = camY - dragOffsetY
    elseif isDragging and selectedObject and scaling then
        local mouseX, mouseY = love.mouse.getPosition()
        local camX, camY = mouseX / camera.scale + camera.x, mouseY / camera.scale + camera.y

        -- Calculate new width and height based on mouse position
        local newWidth = camX - selectedObject.x
        local newHeight = camY - selectedObject.y

        -- Make sure the width and height are non-negative
        selectedObject.width = math.max(newWidth, 1)
        selectedObject.height = math.max(newHeight, 1)
    end

    sceneManager:update(dt)

    if love.keyboard.isDown("w") and running == false then
        camera:move(0, -10)
    end

    if love.keyboard.isDown("s") and running == false then
        camera:move(0, 10)
    end

    if love.keyboard.isDown("d") and running == false then
        camera:move(10, 0)
    end

    if love.keyboard.isDown("a") and running == false then
        camera:move(-10, 0)
    end

    if love.keyboard.isDown("=") and running == false then
        camera:zoom(1.1)
    end

    if love.keyboard.isDown("-") and running == false then
        camera:zoom(0.9)
    end
end

function engine:mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left mouse button
        if ideTest == false then
            if x >= sidebarX and x <= sidebarX + sidebarWidth and y >= sidebarY and y <= sidebarY + sidebarHeight then
                -- Click is within the sidebar, do not deselect
                return
            end
            
            -- Check if an object is clicked
            camX, camY = x / camera.scale + camera.x, y / camera.scale + camera.y
            for index, obj in ipairs(objects) do
                if obj:isClicked(camX, camY) then
                    selectedObject = obj
                    isDragging = true

                    -- Calculate the drag offset
                    dragOffsetX = camX - selectedObject.x
                    dragOffsetY = camY - selectedObject.y

                    -- Update ObjectName label with the corresponding name from ObjectList
                    ObjectName:setText(ObjectList[index])
                    return
                end
            end

            -- Deselect if clicked outside any object
            selectedObject = nil
        end
    end
end

function engine:mousereleased(x, y, button, istouch, presses)
	if button == 1 then -- Left mouse button
        isDragging = false
    end
end

function engine:keypressed(key)
    if key == "f5" and InEngine then
        running = not running
    elseif key == "f" and running == false then
        camera:focus(selectedObject)
    elseif key == "delete" and InEngine and running == false and selectedObject then
        -- Find the index of the selected object in the objects table
        for i, obj in ipairs(objects) do
            if obj == selectedObject then
                table.remove(objects, i) -- Remove the selected object
                table.remove(ObjectList, i)
                selectedObject = nil -- Deselect the object
                break
            end
        end
    end
end

function engine:draw()
    if ideTest == false then
        if InEngine then
            love.graphics.setBackgroundColor(0.3, 0.3, 0.3)
            windowWidth = love.graphics.getWidth()
            windowHeight = love.graphics.getHeight()

            -- Apply camera
            camera:apply()

            -- Draw all objects
            for _, obj in ipairs(objects) do
                obj:draw()
            end

            for _, aud in ipairs(audios) do
                aud:draw()
            end

            -- Highlight the selected object
            if selectedObject then
                love.graphics.setColor(1, 0, 0, 0.5)
                love.graphics.rectangle("line", selectedObject.x, selectedObject.y, selectedObject.width, selectedObject.height)
                love.graphics.setColor(1, 1, 1, 1) -- Reset color
            end

            -- Reset camera
            camera:reset()

            sceneManager:draw()
        else
            -- Draw game objects when not in engine
            for _, obj in ipairs(objects) do
                obj:draw()
            end

            for _, aud in ipairs(audios) do
                aud:draw()
            end
        end
    end
end

return engine