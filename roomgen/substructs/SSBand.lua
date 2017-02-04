local SubStruct = require "roomgen.SubStruct"
local SSBand =  Class.create("SSBand", SubStruct)

function SSBand:makeStructure()
	local xOffset = 2
	if self.x + xOffset + 2 > self.maxX then return end
	self.room:setTile("bkg3",self.x - 2,self.y,"band_edge")
	self.room:setTile("bkg3",self.x,self.y,"band")
	while true do
		if (self.x + xOffset  +  2> self.maxX) then
			self.room:setTile("bkg3",self.x + xOffset,self.y,"band_edge", true)
			break
		end
		self.room:setTile("bkg3",self.x + xOffset,self.y,"band")
		xOffset = xOffset + 2
	end
end

return SSBand