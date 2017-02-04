local Structure = require "roomgen.Structure"
local StHoriz = require "roomgen.StHoriz"
local RoomUtils = require "roomgen.RoomUtils"
local StStop =  Class.create("StStop", StHoriz)

function StStop:init( room , evalArea,number,roomgen)
	StHoriz.init(self,room,evalArea,number,roomgen)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
	self.structType = "StStop"
end

function StStop:makeStructure(left, top,width, height,centX,centY ,reverse )
	self.x = centX 
	self.y = centY
	local converted
	local topWall = {{x=0,y=0},{x=8,y=0}}
	converted = RoomUtils.offset(topWall,self.x, self.y)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addSlopes( converted,false,nil,nil,true)

	converted = RoomUtils.offset(topWall,self.x, self.y + 6)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addSlopes( converted,false,nil,nil,true)

	local midWall = {{x=0,y=0},{x=4,y=0}}
	if reverse then
		converted = RoomUtils.offset(midWall,self.x, self.y + 3)
	else
		converted = RoomUtils.offset(midWall,self.x + 4, self.y + 3)
	end
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addSlopes( converted,false,nil,nil,true)

	local sideWall = {{ x = 0, y = 0},
				{ x = 2, y = 0},
				{ x = 2, y = 8},
				{ x = 0, y = 8 }}
	if reverse then
		converted = RoomUtils.offset(sideWall,self.x+6,self.y)
		self:addZone("rightSide",self.x + 6, self.y,self.x + 6, self.y + 8,1)
		self:addZone("side",self.x + 6, self.y,self.x + 6, self.y + 8,1)
	else
		converted = RoomUtils.offset(sideWall,self.x,self.y)
		self:addZone("leftSide",self.x + 2, self.y,self.x + 2, self.y + 8,1)
		self:addZone("side",self.x + 2, self.y,self.x + 2, self.y + 8,1)
	end
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)


	self.minX = centX
	self.maxX = centX
	self.minY = centY
	self.maxY = centY
	self:fillPositions()
end 

function StStop:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness )
end

return StStop