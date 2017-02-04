local SubStruct = require "roomgen.SubStruct"
local SSLargeWindow =  Class.create("SSLargeWindow", SubStruct)

function SSLargeWindow:makeStructure()
	self.room:setTile("bkg2",self.x,self.y,"window_largeTop")
	self.room:setTile("bkg2",self.x,self.y + 2,"window_largeBottom")
end

return SSLargeWindow