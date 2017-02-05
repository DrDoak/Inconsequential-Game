local SubStruct = require "roomgen.SubStruct"
-- local ObjLeak = require "objects.ObjLeak"
local SSChest =  Class.create("SSChest", SubStruct)

function SSChest:makeStructure()
	local xOffset = 2
	if self.x + xOffset + 2> self.maxX then return end
	
	-- self.room:addRectangleObj("lvl.ObjChestCoin",self.x,self.y - 1,2,2,nil)
end

return SSChest