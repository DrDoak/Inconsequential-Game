local StHoriz = require "roomgen.StHoriz"
local RoomUtils = require "roomgen.RoomUtils"
local ExHoriz =  Class.create("ExHoriz", StHoriz)

function ExHoriz:init( room, evalArea, number,roomgen)
	StHoriz.init(self,room,evalArea, number, roomgen)
	self.structType = "ExHoriz"
end

function ExHoriz:makeStructure(left, top,width, height,centX,centY ,reverse )
	self.groundLevel = centY + 6
	self:addGround(centX, centY,8, 8,centX,centY ,false )
	-- lume.trace("Adding Exit Structure")
	--self:addCeiling(centX, centY,8, 8,centX,centY ,false , 8  )
	if reverse then
		self.room:addRectangleObj("ObjLevelChanger",centX + 6,centY,2,8,{newX = self.newX,newY = self.newY,nextRoom= self.nextRoom or "Gen", dir = "right", prevY = self.prevY, prevX = self.prevX})
	else
		self.room:addRectangleObj("ObjLevelChanger",centX,centY,2,8,{newX = self.newX,newY = self.newY,nextRoom= self.nextRoom or "Gen", dir = "left", prevY = self.prevY, prevX = self.prevX})
	end

	-- lume.trace("Current value stored in nextRoom: " , self.nextRoom)
	self.minX = self.x
	self.maxX = self.x + 8
	self.minY = self.y
	self.maxY = self.y 
	self.structType = "ExHoriz"
	self:fillPositions()
	--self:fillBackground("wall")
end

return ExHoriz