local RoomUtils = require "roomgen.RoomUtils"
local StCross = require "roomgen.StCross"
local ExTop =  Class.create("ExTop", StCross)

function ExTop:makeStructure(left, top,width, height,centX,centY ,reverse )
	self.structType = "ExTop"
	StCross.makeStructure(self, left, top,width, height,centX,centY ,reverse )
	-- self.x = centX 
	-- self.y = centY
	-- local converted
	-- local topWall = {{x=0,y=0},{x=8,y=0}}
	-- converted = RoomUtils.offset(topWall,self.x, self.y)
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addSlopes( converted,false,nil,nil,true)

	-- converted = RoomUtils.offset(topWall,self.x, self.y + 8)
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addSlopes( converted,false,nil,nil,true)

	-- local midWall = {{x=0,y=0},{x=4,y=0}}
	-- if reverse then
	-- 	converted = RoomUtils.offset(midWall,self.x, self.y + 3)
	-- else
	-- 	converted = RoomUtils.offset(midWall,self.x + 4, self.y + 3)
	-- end
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addSlopes( converted,false,nil,nil,true)

	-- local sideWall = {{ x = 0, y = 0},
	-- 			{ x = 4, y = 0},
	-- 			{ x = 4, y = 8},
	-- 			{ x = 0, y = 8 }}
	-- if reverse then
	-- 	converted = RoomUtils.offset(sideWall,self.x+4,self.y)
	-- else
	-- 	converted = RoomUtils.offset(sideWall,self.x,self.y)
	-- end
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addEnclosedArea(converted)
	self.room:addRectangleObj("ObjLevelChanger",centX,centY,8,2,{newX = self.newX,newY = self.newY,nextRoom= self.nextRoom or "Gen", dir = "up", prevY = self.prevY, prevX = self.prevX})

	-- self.minX = centX
	-- self.maxX = centX
	-- self.minY = centY
	-- self.maxY = centY
	-- self:fillPositions()
	--self:fillBackground("wall")
end 

return ExTop