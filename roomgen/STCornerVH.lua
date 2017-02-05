local StStandard = require "roomgen.StStandard"
local RoomUtils = require "roomgen.RoomUtils"
local STCornerVH =  Class.create("STCornerVH", StStandard)

function STCornerVH:init( room , evalArea, number,roomgen)
	StStandard.init(self,room,evalArea, number, roomgen)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
	self.structType = "StCornerVH"
end

function STCornerVH:makeStructure(left, top,width, height,centX,centY ,reverse )
	if not reverse then
		self:addLeftWall(centX, centY,8, 8,centX,centY ,false )
	else
		self:addRightWall(centX, centY,8, 8,centX,centY ,false )
	end
	self:addTopWall(centX, centY,8, 8,centX,centY ,false )

	self.minX = self.x
	self.maxX = self.x 
	self.minY = self.y
	self.maxY = self.y 
	self.structType = "StCornerVH"
	self:fillPositions()
end

function STCornerVH:checkCollide(structure)
	return false
end
function STCornerVH:hasExit()
	return true
end
function STCornerVH:canHandleExists()
	return true
end

return STCornerVH