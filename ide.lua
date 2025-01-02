local ide = {}

local mode = "text" -- either text mode or visual mode

function ide.load()
	
end

function ide.draw()

end

function ide.update(dt)
	if self.focused then
        -- Handle text input
        if love.keyboard.isDown("backspace") then
            if #self.text > 0 then
                self.text = self.text:sub(1, -2)
                self.cursorPos = #self.text + 1
            end
        end

        -- Use keypressed for discrete input instead of getPressed
        local function textInputHandler(text)
            if text:len() == 1 then
                self.text = self.text:sub(1, self.cursorPos - 1) .. text .. self.text:sub(self.cursorPos)
                self.cursorPos = self.cursorPos + 1
            end
        end

        -- Attach text input handling (see `love.textinput`)
        function love.textinput(text)
            if self.focused then
                textInputHandler(text)
            end
        end
    end
end