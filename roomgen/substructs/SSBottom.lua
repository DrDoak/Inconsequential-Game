local SubStruct = require "roomgen.SubStruct"
local SSBottom =  Class.create("SSBottom", SubStruct)

function SSBottom:makeStructure()
	-- lume.trace("SSBottom added with first x: ", self.x, "MaxX: ", self.maxX)
	local xOffset = 2
	if self.x + xOffset + 2 > self.maxX then return end
	self.room:setTile("bkg3",self.x - 2,self.y,"baseBoard_edge")
	self.room:setTile("bkg3",self.x,self.y,"baseBoard")
	while true do
		if (self.x + xOffset + 2 > self.maxX) then
			self.room:setTile("bkg3",self.x + xOffset,self.y,"baseBoard_edge", true)
			break
		end
		-- lume.trace("XOffset: ", xOffset)
		self.room:setTile("bkg3",self.x + xOffset,self.y,"baseBoard")
		xOffset = xOffset + 2
	end
end

return SSBottom