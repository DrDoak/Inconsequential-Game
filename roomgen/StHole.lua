local StHoriz = require "roomgen.StHoriz"
local RoomUtils = require "roomgen.RoomUtils"
local StHole =  Class.create("StHole", StHoriz)

function StHole:makeStructure(left, top,width, height,centX,centY ,reverse )
	self.groundLevel = centY + 6
	self:addHole(centX, centY,8, 8,centX,centY ,false )
	self:addCeiling(centX, centY,8, 8,centX,centY ,false , 8  )


	self.minX = self.x
	self.maxX = self.x + 8
	self.minY = self.y
	self.maxY = self.y 
	self.structType = "StHole"
	self:fillPositions()
end

function StHole:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness )
end

return StHole