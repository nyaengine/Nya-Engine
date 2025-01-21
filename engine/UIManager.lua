UIManager = {}
UIManager.__index = UIManager

function UIManager:new()
    local ui = setmetatable({}, self)
    ui.elements = {}
    return ui
end

function UIManager:addElement(element)
    table.insert(self.elements, element)
end

function UIManager:draw()
    for _, element in ipairs(self.elements) do
        element:draw()
    end
end

return UIManager