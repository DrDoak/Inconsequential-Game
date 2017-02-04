local SubStruct = require "roomgen.SubStruct"
local SSLowFence =  Class.create("SSLowFence", SubStruct)

function SSLowFence:makeStructure()
	local xOffset = 2
	if self.x + xOffset + 2 > self.maxX then return end
	local height = 2
	self.room:setTile("bkg3",self.x,self.y,"fenceLow_edge")
	while true do
		if (self.x + xOffset  + 4 > self.maxX) or math.random(1,6) == 1 then
			local curHeight = 0
			while true do
				self.room:setTile("bkg3",self.x + xOffset,self.y - curHeight,"fenceLow_edge", true)
				curHeight = curHeight + 2
				if curHeight >= 2 then
					break
				end
			end
			break
		end
		local curHeight = 0
		while true do
			self.room:setTile("bkg3",self.x + xOffset,self.y - curHeight,"fenceLow")
			curHeight = curHeight + 2
			if curHeight >= 2 then
				break
			end
		end
		xOffset = xOffset + 2
	end
end

return SSLowFence