local StHoriz = require "roomgen.StHoriz"
local RoomUtils = require "roomgen.RoomUtils"
local StCross = require "roomgen.StCross"
local ExBottom =  Class.create("ExBottom", StHoriz)

function ExBottom:makeStructure(left, top,width, height,centX,centY ,reverse )
	self.structType = "ExBottom"
	self:addLeftWall(centX, centY,8, 8,centX,centY ,false )
	self:addRightWall(centX, centY,8, 8,centX,centY ,false )
	self.room:addRectangleObj("ObjRoomChanger",centX,centY + 6,8,2,{newX = self.newX,newY = self.newY,nextRoom= self.nextRoom or "Gen", dir = "down", prevY = self.prevY, prevX = self.prevX})
	self.minX = centX
	self.maxX = centX
	self.minY = centY
	self.maxY = centY
	self:fillPositions()
end 
return ExBottom