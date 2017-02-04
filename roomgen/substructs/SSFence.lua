local SubStruct = require "roomgen.SubStruct"
local SSFence =  Class.create("SSFence", SubStruct)

function SSFence:makeStructure()
	local xOffset = 2
	if self.x + xOffset + 2 > self.maxX then return end
	local height = math.random(6,math.min(10, self.y - self.minY))
	local curHeight = 0
	while true do
		self.room:setTile("fground2",self.x,self.y - curHeight,"fence_edge")
		curHeight = curHeight + 2
		if curHeight >= height then
			break
		end
	end

	while true do
		if (self.x + xOffset  + 4 > self.maxX) or math.random(1,6) == 1 then
			local curHeight = 0
			while true do
				self.room:setTile("fground2",self.x + xOffset,self.y - curHeight,"fence_edge", true)
				curHeight = curHeight + 2
				if curHeight >= height then
					break
				end
			end
			break
		end
		local curHeight = 0
		while true do
			self.room:setTile("fground2",self.x + xOffset,self.y - curHeight,"fence")
			curHeight = curHeight + 2
			if curHeight >= height then
				break
			end
		end
		xOffset = xOffset + 2
	end
end

return SSFence