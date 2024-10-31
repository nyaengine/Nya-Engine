-- nodes.lua
local Node = {}
Node.__index = Node

function Node:new(name)
    local node = {
        name = name,
        inputs = {},
        outputs = {},
        executed = false
    }
    setmetatable(node, self)
    return node
end

function Node:addInput(name)
    table.insert(self.inputs, { name = name, value = nil, connectedNode = nil })
end

function Node:addOutput(name)
    table.insert(self.outputs, { name = name, connectedNodes = {} })
end

function Node:setInputValue(name, value)
    for _, input in ipairs(self.inputs) do
        if input.name == name then
            input.value = value
        end
    end
end

function Node:getOutputValue(name)
    for _, output in ipairs(self.outputs) do
        if output.name == name then
            return output.value
        end
    end
end

function Node:connect(outputName, targetNode, targetInputName)
    for _, output in ipairs(self.outputs) do
        if output.name == outputName then
            table.insert(output.connectedNodes, { node = targetNode, inputName = targetInputName })
        end
    end
end

function Node:execute()
    if not self.executed then
        self:evaluate()
        self.executed = true
        for _, output in ipairs(self.outputs) do
            for _, connection in ipairs(output.connectedNodes) do
                connection.node:setInputValue(connection.inputName, output.value)
                connection.node:execute()
            end
        end
    end
end

function Node:evaluate()
    -- To be implemented by subclasses
end

-- Define a few specific node types

-- Variable Node
local VariableNode = setmetatable({}, { __index = Node })
VariableNode.__index = VariableNode

function VariableNode:new(name, value)
    local node = Node.new(self, name)
    node:addOutput("value")
    node.value = value
    return node
end

function VariableNode:evaluate()
    self.outputs[1].value = self.value
end

-- Add Node
local AddNode = setmetatable({}, { __index = Node })
AddNode.__index = AddNode

function AddNode:new(name)
    local node = Node.new(self, name)
    node:addInput("a")
    node:addInput("b")
    node:addOutput("result")
    return node
end

function AddNode:evaluate()
    local a = self.inputs[1].value or 0
    local b = self.inputs[2].value or 0
    self.outputs[1].value = a + b
end

-- Print Node
local PrintNode = setmetatable({}, { __index = Node })
PrintNode.__index = PrintNode

function PrintNode:new(name)
    local node = Node.new(self, name)
    node:addInput("value")
    return node
end

function PrintNode:evaluate()
    local value = self.inputs[1].value
    print(self.name .. ": " .. tostring(value))
end

-- Factory function to create nodes
local function createNode(nodeType, name, ...)
    if nodeType == "variable" then
        return VariableNode:new(name, ...)
    elseif nodeType == "add" then
        return AddNode:new(name)
    elseif nodeType == "print" then
        return PrintNode:new(name)
    else
        error("Unknown node type: " .. tostring(nodeType))
    end
end

return {
    createNode = createNode
}
