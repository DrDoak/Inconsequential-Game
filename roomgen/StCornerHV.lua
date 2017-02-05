local StStandard = require "roomgen.StStandard"
local RoomUtils = require "roomgen.RoomUtils"
local STCornerHV =  Class.create("STCornerHV", StStandard)

function STCornerHV:init( room , evalArea,number,roomgen)
	lume.trace("initializing corderHV: ", roomgen)
	StStandard.init(self,room,evalArea, number, roomgen)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
	self.structType = "StCornerHV"
end

function STCornerHV:makeStructure(left, top,width, height,centX,centY ,reverse )
	if not reverse then
		self:addLeftWall(centX, centY,8, 8,centX,centY ,false )
	else
		self:addRightWall(centX, centY,8, 8,centX,centY ,false )
	end
	self:addBottomWall(centX, centY,8, 8,centX,centY ,false )

	self.minX = self.x
	self.maxX = self.x + 8
	self.minY = self.y
	self.maxY = self.y 

	self:fillPositions()
end

function STCornerHV:checkCollide(structure)
	return false
end
function STCornerHV:hasExit()
	return true
end
function STCornerHV:canHandleExists()
	return true
end

return STCornerHV