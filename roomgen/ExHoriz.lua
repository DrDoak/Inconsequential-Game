local StStandard = require "roomgen.StStandard"
local RoomUtils = require "roomgen.RoomUtils"
local ExHoriz =  Class.create("ExHoriz", StStandard)

function ExHoriz:init( room, evalArea, number,roomgen)
	StStandard.init(self,room,evalArea, number, roomgen)
	self.structType = "ExHoriz"
end

function ExHoriz:makeStructure(left, top,width, height,centX,centY ,reverse )
	self.groundLevel = centY + 8
	self:addBottomWall(centX, centY,8, 8,centX,centY ,false )
	self:addTopWall(centX, centY,8, 8,centX,centY ,false )
	if reverse then
		self.room:addRectangleObj("ObjRoomChanger",centX + 6,centY,2,8,{newX = self.newX,newY = self.newY,nextRoom= self.nextRoom or "Gen", dir = "right", prevY = self.prevY, prevX = self.prevX})
	else
		self.room:addRectangleObj("ObjRoomChanger",centX,centY,2,8,{newX = self.newX,newY = self.newY,nextRoom= self.nextRoom or "Gen", dir = "left", prevY = self.prevY, prevX = self.prevX})
	end

	self.minX = self.x
	self.maxX = self.x + 8
	self.minY = self.y
	self.maxY = self.y 
	self.structType = "ExHoriz"
	self:fillPositions()
end

return ExHoriz