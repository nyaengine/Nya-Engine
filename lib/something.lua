local something = {}
something.__index = something

function something:new(smth)
		smth = smth or {}
		setmetatable(smth, self)
		self.__index = self

		smth.x = smth.x or 0
		smth.y = smth.y or 0
		smth.width = smth.width or 50
		smth.height = smth.height or 50
		smth.bgClr = smth.bgClr or {1, 1, 1, 1}

		return smth
end

function something:draw()
		love.graphics.setColor(self.bgClr)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
		love.graphics.setColor(1, 1, 1, 1)
end

function something:setSize(width, height)
		self.width = width 
		self.height = height
end

return something