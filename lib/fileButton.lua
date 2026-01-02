local fileButton = {}
fileButton.__index = fileButton

-- Create a new file select button
function fileButton.new(opts)
    local self = setmetatable({}, fileButton)

    self.x = opts.x or 0
    self.y = opts.y or 0
    self.w = opts.w or 160
    self.h = opts.h or 30

    self.label = opts.label or "Select File"
    self.startPath = opts.startPath or "project"
    self.filter = opts.filter -- { "png", "lua", ... }

    self.value = nil
    self.onChange = opts.onChange

    return self
end

function fileButton:setCallback(fn)
    self.onChange = fn
end

function fileButton:getValue()
    return self.value
end

function fileButton:openDialog()
    if self.filter then
        fileDialog.setFilter(self.filter)
    else
        fileDialog.clearFilter()
    end

    fileDialog.setCallback(function(path)
        self.value = path
        if self.onChange then
            self.onChange(path)
        end
    end)

    fileDialog.open(self.startPath)
end

function fileButton:draw()
    -- Button background
    love.graphics.setColor(preferences.getColor("button", "background"))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 4, 4)

    -- Text
    love.graphics.setColor(preferences.getColor("label", "textColor"))
    love.graphics.print(self.label, self.x + 8, self.y + 7)

    -- Selected file preview
    if self.value then
        love.graphics.setColor(preferences.getColor("label", "textColor"))
        love.graphics.print(
            love.filesystem.getBaseDirectory and self.value or self.value,
            self.x,
            self.y + self.h + 4
        )
    end
end

function fileButton:mousepressed(mx, my, button)
    if button ~= 1 then return end

    if mx >= self.x and mx <= self.x + self.w and
       my >= self.y and my <= self.y + self.h then
        self:openDialog()
    end
end

return fileButton
