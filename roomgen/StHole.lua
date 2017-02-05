local StStandard = require "roomgen.StStandard"
local RoomUtils = require "roomgen.RoomUtils"
local StHole =  Class.create("StHole", StStandard)

function StHole:makeStructure(left, top,width, height,centX,centY ,reverse )
	self:addTopWall(centX, centY,8, 8,centX,centY ,false )

	self.minX = self.x
	self.maxX = self.x 
	self.minY = self.y
	self.maxY = self.y 
	self.structType = "StHole"
	self:fillPositions()
end

function StHole:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness )
end

return StHole