local SubStruct = require "roomgen.SubStruct"
local SSHangingLight =  Class.create("SSHangingLight", SubStruct)

function SSHangingLight:makeStructure()
	lume.trace(self.maxY, self.minY, math.abs(self.maxY - self.minY))
	if math.abs(self.maxY - self.minY) > 6 then
		-- self.room:addRectangleObj("lvl.ObjChainLight",self.x + 1,self.y - 0.5,2,2,{numLinks=3})--,{angle=90,lType="spotlight",radius=80,width=7})
	end
end

return SSHangingLight