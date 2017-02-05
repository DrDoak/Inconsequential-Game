local StStandard = require "roomgen.StStandard"
local RoomUtils = require "roomgen.RoomUtils"
local StStop =  Class.create("StStop", StStandard)

function StStop:init( room , evalArea,number,roomgen)
	StStandard.init(self,room,evalArea,number,roomgen)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
	self.structType = "StStop"
end

function StStop:makeStructure(left, top,width, height,centX,centY ,reverse )
	self:addLeftWall(centX, centY,8, 8,centX,centY ,reverse )

	self.minX = self.x
	self.maxX = self.x 
	self.minY = self.y
	self.maxY = self.y 
	self:fillPositions()
end 

function StStop:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness )
end

return StStop