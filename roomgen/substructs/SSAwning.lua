local SubStruct = require "roomgen.SubStruct"
local SSAwning =  Class.create("SSAwning", SubStruct)

function SSAwning:makeStructure()
	self.room:setTile("bkg2",self.x,self.y,"pipe_corner")
	local xOffset = 0
	while true do
		break
	end
	self.room:setTile("bkg2",self.x,self.y + 2,"window_largeBottom")
end

return SSAwning