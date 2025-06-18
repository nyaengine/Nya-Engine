-- lib/frame.lua
local Frame = {}

function Frame.new(x, y, width, height, visible)
    local self = {
        x = x or 0,
        y = y or 0,
        width = width or 100,
        height = height or 100,
        visible = visible or true,
        color = {1, 1, 1, 1},
        children = {}
    }
    
    function self:draw()
        if self.visible then
            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        end
    end
    
    function self:update(dt)
        -- Update logic for the frame
    end
    
    return self
end

return Frame