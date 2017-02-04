local StHoriz = require "roomgen.StHoriz"
local RoomUtils = require "roomgen.RoomUtils"
local StCross =  Class.create("StCross", StHoriz)

function StCross:init( room , evalArea,num,roomgen)
	StHoriz.init(self,room,evalArea,num,roomgen)
	self.structType = "StCross"
end

function StCross:makeStructure(left, top,width, height,centX,centY ,reverse )
	-- self:addHole(left, top,width, height,centX,centY ,true )
	-- self:addCeilHole(left, top,width, height,centX,centY ,true , 8  )
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
	self:addZone("ground",self.x, self.y+4, 8, 2,1)
	--self:addZone("ground",self.x, self.y + 6,self.x + 8, self.y + 6,1)

	local midWall = {{x=0,y=0},{x=4,y=0}}
	converted = RoomUtils.offset(midWall,self.x + 2, self.y + 3)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addSlopes( converted,false,nil,nil,true)
	self:addZone("ground",self.x+2, self.y+1, 4, 2,1)
	--self:addZone("ground",self.x + 2, self.y+3,self.x + 6, self.y+3,1)

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