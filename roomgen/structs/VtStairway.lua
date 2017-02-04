local StVert = require "roomgen.StVert"
local RoomUtils = require "roomgen.RoomUtils"
local VtStairway =  Class.create("VtStairway", StVert)

function VtStairway:init( room, evalArea, number, roomgen)
	StVert.init(self,room,evalArea, number, roomgen)
	self.structType = "VtStairway"
	self:setMinArea(3,0,1,0)
	self.maxGap = 32
end

function VtStairway:makeStructure(left, top,width, height,centX,centY ,reverse )
	self:makeEnclosure(left,top,width,height,centX,centY,reverse)
	self:makeStairs(left, top,width, height,centX,centY ,reverse )
	self:fillBackground("wall")
	self:interSpaceTile("curve_edge","bkg2","leftSide",nil,1.0,nil)
	self:interSpaceTile("curve_edge","bkg2","rightSide",nil,1.0,nil, true)
end

function VtStairway:makeStairs(left, top,width, height,centX,centY ,reverse )
	if self.gap > 20 then
		self.slope = 0.5
	else
		self.slope = 1
	end
	self.platformWidth = (self.gap - 8 * (1/self.slope))/2
	self.platformHeight = 4

	self:addSidePlatforms(self.platformWidth, self.platformHeight,  reverse) 

	local posY = self.maxY 
	local converted, converted2,sideConvert
	local leftPlat = not reverse

	-- local sideWall = {{ x = 0 , y = 0},
	-- 	{ x = self.platformWidth , y = 0},
	-- 	{ x = self.platformWidth , y = self.platformHeight},
	-- 	{ x = 0 , y = self.platformHeight}}
	local slopeRight = {{ x = 0, y = 8},
		{ x = 8 * (1/self.slope), y = 0}}
	local slopeLeft = {{ x = 0, y = 0},
		{ x = 8 * (1/self.slope), y = 8}}
	-- local middleWall = {{ x = 0, y = 0},
	-- 	{ x = self.platformWidth, y = 0}}
	while (posY > self.minY) do
		-- if posY <= self.minY + 8 then
		-- 	if not reverse then
		-- 		-- sideConvert = RoomUtils.offset(sideWall, self.leftWallPos, posY - 2)
		-- 		converted2 = RoomUtils.offset(middleWall,self.leftWallPos, posY - 2)
		-- 	else
		-- 		-- sideConvert = RoomUtils.offset(sideWall, self.leftWallPos, posY - 2)
		-- 		converted2 = RoomUtils.offset(middleWall,self.leftWallPos, posY - 2)
		-- 	end
		-- 	--sideConvert = RoomUtils.toAbsCoords(sideConvert)
		-- 	--self.room:addEnclosedArea(sideConvert)
		-- 	converted2 = RoomUtils.toAbsCoords(converted2)
		-- 	self.room:addSlopes(converted2,false,nil,nil,true)
		-- 	converted2 = RoomUtils.offset(converted2,0,-64)
		-- 	self.room:addSlopes(converted2,false,nil,nil,true)
		-- 	converted2 = RoomUtils.offset(converted2,0,-64)
		-- 	self.room:addSlopes(converted2,false,nil,nil,true)

		-- 	if not leftPlat then
		-- 		converted = RoomUtils.offset(slopeLeft, self.leftWallPos + self.platformWidth, posY - 8)
		-- 	else
		-- 		converted = RoomUtils.offset(slopeRight, self.leftWallPos + self.platformWidth - 4, posY - 8)
		-- 	end
		-- 	converted = RoomUtils.toAbsCoords(converted)
		-- 	self.room:addSlopes( converted,false,nil,nil,true)
		-- 	break
		-- end

		if not leftPlat then
			--sideConvert = RoomUtils.offset(sideWall, self.leftWallPos, posY - 8)
			converted = RoomUtils.offset(slopeLeft, self.leftWallPos + self.platformWidth, posY - 8)
		else
			--sideConvert = RoomUtils.offset(sideWall,self.rightWallPos - self.platformWidth, posY - 8)
			converted = RoomUtils.offset(slopeRight, self.leftWallPos + self.platformWidth - 4, posY - 8)
		end
		converted = RoomUtils.toAbsCoords(converted)
		self.room:addSlopes( converted,false,nil,nil,true,true)
		-- sideConvert = RoomUtils.toAbsCoords(sideConvert)
		-- util.print_table(sideConvert)
		--self.room:addEnclosedArea( sideConvert )
		posY = posY - 8
		leftPlat = not leftPlat
	end
end

return VtStairway