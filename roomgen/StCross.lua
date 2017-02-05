local StStandard = require "roomgen.StStandard"
local RoomUtils = require "roomgen.RoomUtils"
local StCross =  Class.create("StCross", StStandard)

function StCross:init( room , evalArea,num,roomgen)
	StStandard.init(self,room,evalArea,num,roomgen)
	self.structType = "StCross"
end

function StCross:makeStructure(left, top,width, height,centX,centY ,reverse )
	self.minX = centX
	self.maxX = centX
	self.minY = centY
	self.maxY = centY
	self:fillPositions()
end

function StCross:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness )
end

return StCross