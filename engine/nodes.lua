local nodes = {}
nodes.__index = nodes

function nodes:new(node)
	node = node or {}
	setmetatable(node, self)
	self.__index = self

	node.x = node.x or 0
	node.y = node.y or 0
	node.width = node.width or 50
	node.height = node.height or 50
	node.connectedNodes = {}

	return node
end

function nodes:draw()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function nodes:addNode(node)
	table.insert(self.connectedNodes, node)
end

return nodes