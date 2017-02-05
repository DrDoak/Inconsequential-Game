local SubStruct = require "roomgen.SubStruct"
local SSLightSide =  Class.create("SSLightSide", SubStruct)

function SSLightSide:makeStructure()
	-- lume.trace("SSGroundLight" , self.side)
	if self.side == "left" then
		self.room:setTile("fground",self.x,self.y,"light_side")
	else
		self.room:setTile("fground",self.x,self.y,"light_side",true)
	end
	-- self.room:addRectangleObj("ObjLight",self.x + 1,self.y + 1.5,2,2,{radius=120})
end

return SSLightSide