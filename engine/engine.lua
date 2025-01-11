local engine = {}

--Game objects
objects = {}
CollisionObjects = {}
selectedObject = nil
local running = false
local isDragging = false
sceneManager = SceneManager:new()
local camera = Camera:new(0, 0, 1)

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

function engine:draw()
	if ideTest == false then
		love.graphics.setBackgroundColor(0.3, 0.3, 0.3)
		windowWidth = love.graphics.getWidth()
    	windowHeight = love.graphics.getHeight()

    	-- Apply camera
    	camera:apply()

    	-- Draw all objects
    	for _, obj in ipairs(objects) do
        	obj:draw()
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
	end
end

return engine