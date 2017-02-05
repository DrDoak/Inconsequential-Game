local RoomUtils = require "roomgen.RoomUtils"
local StCross = require "roomgen.StCross"
local ExTop =  Class.create("ExTop", StCross)

function ExTop:makeStructure(left, top,width, height,centX,centY ,reverse )
	self.structType = "ExTop"
	self:addLeftWall(centX, centY,8, 8,centX,centY ,false )
	self:addRightWall(centX, centY,8, 8,centX,centY ,false )
	self.room:addRectangleObj("ObjRoomChanger",centX,centY,8,2,{newX = self.newX,newY = self.newY,nextRoom= self.nextRoom or "Gen", dir = "up", prevY = self.prevY, prevX = self.prevX})

	self.minX = centX
	self.maxX = centX
	self.minY = centY
	self.maxY = centY
	self:fillPositions()
end 

return ExTop