local SubStruct = require "roomgen.SubStruct"
local SSGroundLight =  Class.create("SSGroundLight", SubStruct)

function SSGroundLight:makeStructure()
	self.room:setTile("fground",self.x,self.y,"light_ground")
	-- self.room:addRectangleObj("ObjLight",self.x + 1,self.y + 3,2,2,{angle=270,lType="spotlight",radius=80,width=4})
end

return SSGroundLight