local SubStruct = require "roomgen.SubStruct"
local SSVending =  Class.create("SSVending", SubStruct)

function SSVending:makeStructure()
	local xOffset = 2
	if self.x + xOffset + 2> self.maxX then return end
	
	-- self.room:addRectangleObj("lvl.ObjVending",self.x,self.y - 1,2,2,nil)
end

return SSVending