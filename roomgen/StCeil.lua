local StStandard = require "roomgen.StStandard"
local RoomUtils = require "roomgen.RoomUtils"
local StCeil =  Class.create("StCeil", StStandard)

function StCeil:makeStructure(left, top,width, height,centX,centY ,reverse )
	self:addBottomWall(centX, centY,8, 8,centX,centY ,false )

	self.minX = self.x
	self.maxX = self.x 
	self.minY = self.y
	self.maxY = self.y 
	self.structType = "StCeil"
	self:fillPositions()
end

function StCeil:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness )
end

return StCeil