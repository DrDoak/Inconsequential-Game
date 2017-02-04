local SubStruct = require "roomgen.SubStruct"
local SSCeilingLight =  Class.create("SSCeilingLight", SubStruct)

function SSCeilingLight:makeStructure()
	self.room:setTile("fground",self.x,self.y,"light_ceiling")
	self.room:addRectangleObj("ObjLight",self.x + 1,self.y + 1.5,2,2,{angle=90,lType="spotlight",radius=80,width=7})
end

return SSCeilingLight