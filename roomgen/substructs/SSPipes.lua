local SubStruct = require "roomgen.SubStruct"
-- local ObjLeak = require "objects.ObjLeak"
local SSPipes =  Class.create("SSPipes", SubStruct)

function SSPipes:makeStructure()
	local xOffset = 2
	if self.x + xOffset + 2> self.maxX then return end
	self.room:setTile("fground",self.x,self.y,"pipe_corner")
	while true do
		if Game.genRand:random(1,5) == 1 then
			self.room:addRectangleObj("spwn.SpwnLeak",(self.x + xOffset),self.y+2,2,2,nil)
		end

		if (self.x + xOffset  + 4 > self.maxX) or Game.genRand:random(1,7) == 1 then
			self.room:setTile("fground",self.x + xOffset,self.y,"pipe_corner", true)
			break
		end
		self.room:setTile("fground",self.x + xOffset,self.y,"pipe")

		xOffset = xOffset + 2
	end
end

return SSPipes