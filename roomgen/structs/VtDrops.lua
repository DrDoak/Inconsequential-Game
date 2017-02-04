local StVert = require "roomgen.StVert"
local RoomUtils = require "roomgen.RoomUtils"
local VtDrops =  Class.create("VtDrops", StVert)

function VtDrops:init( room, evalArea, number, roomgen)
	StVert.init(self,room,evalArea, number, roomgen)
	self.structType = "VtDrops"
	self:setMinArea(3,0,1,0)
	self.maxGap = 32
end

function VtDrops:makeStructure(left, top,width, height,centX,centY ,reverse )
	self:makeEnclosure(left, top,width, height,centX,centY ,reverse )
	lume.trace("VTDrops: ", self.gap, "width: ", width)
	self.platformWidth = math.max(2,self.gap - 12)
	lume.trace("width: ", self.platformWidth)
	self.platformHeight = 4

	local leftPlat = not reverse

	local sideWall = {{ x = 0 , y = 0},
		{ x = self.platformWidth , y = 0},
		{ x = self.platformWidth , y = self.platformHeight},
		{ x = 0 , y = self.platformHeight}}
	local smallWall = false

	if self.platformWidth > 8 then
		self.smallWallSize = 4
	elseif self.platformWidth > 4 then
		self.smallWallSize = 2
	else
		self.smallWallSize = 0
	end
	smallWall = {{ x = 0 , y = 0},
		{ x = self.smallWallSize , y = 0},
		{ x = self.smallWallSize , y = self.platformHeight},
		{ x = 0 , y = self.platformHeight}}
	self.holeSize = math.max(2,(self.gap - self.smallWallSize - self.platformWidth ))
	local jumpThru = {{x = 0, y = 0},
		{ x = self.holeSize , y = 0}}
	local posY = self.maxY 
	local smallConvert, sideConvert, holeConvert

	while (posY > self.minY) do
		if posY <= self.minY + 8 then
			if not reverse then
				smallConvert = RoomUtils.offset(jumpThru,self.leftWallPos, posY - 4)
			else
				smallConvert = RoomUtils.offset(jumpThru,self.leftWallPos, posY - 4)
			end
			smallConvert = RoomUtils.toAbsCoords(smallConvert)
			self.room:addSlopes(smallConvert,false,nil,nil,true)
			smallConvert = RoomUtils.offset(smallConvert,0,-64)
			self.room:addSlopes(smallConvert,false,nil,nil,true)
			break
		end
		if not leftPlat then
			sideConvert = RoomUtils.offset(sideWall, self.leftWallPos, posY - 8)
			holeConvert = RoomUtils.offset(jumpThru,self.leftWallPos + self.platformWidth,posY - 8 + self.platformHeight)
			if self.smallWallSize > 0 then smallConvert = RoomUtils.offset(smallWall, self.rightWallPos - self.smallWallSize, posY - 8) end
		else
			sideConvert = RoomUtils.offset(sideWall,self.rightWallPos - self.platformWidth, posY - 8)
			holeConvert = RoomUtils.offset(jumpThru,self.rightWallPos - self.platformWidth - self.holeSize,posY - 8 + self.platformHeight)
			if self.smallWallSize > 0 then smallConvert = RoomUtils.offset(smallWall, self.leftWallPos, posY - 8) end
		end
		if self.smallWallSize > 0 then
			smallConvert = RoomUtils.toAbsCoords(smallConvert)
			self.room:addEnclosedArea( smallConvert )
		end
		sideConvert = RoomUtils.toAbsCoords(sideConvert)
		self.room:addEnclosedArea( sideConvert )
		holeConvert = RoomUtils.toAbsCoords(holeConvert)
		self.room:addSlopes(holeConvert,false,nil,nil,true)
		posY = posY - 8
		leftPlat = not leftPlat
	end
end

return VtDrops