local StVert = require "roomgen.StVert"
local RoomUtils = require "roomgen.RoomUtils"
local VtJumps = require "roomgen.structs.VtJumps"
local VtJumpsSolid =  Class.create("VtJumpsSolid", StVert)

function VtJumpsSolid:init( room, evalArea, number,roomgen)
	StVert.init(self,room,evalArea, number,roomgen)
	self.structType = "VtJumpsSolid"
	self:setMinArea(2,0,2,0)
	self.maxGap = 32
end

function VtJumpsSolid:makeStructure(left, top,width, height,centX,centY ,reverse )
	lume.trace("Vertical Jump Solid make structure")
	self:makeEnclosure(left,top,width,height,centX,centY,reverse)
	if self.gap <= 4 then
		VtJumps.addJumps(self, left, top,width, height,centX,centY ,reverse )
	else
		self:addJumps(left, top,width, height,centX,centY ,reverse )
	end
	-- self:fillBackground("wall")
	-- self:interSpaceTile("curve_edge","bkg2","leftSide",nil,1.0,nil)
	-- self:interSpaceTile("curve_edge","bkg2","rightSide",nil,1.0,nil, true)
end

function VtJumpsSolid:addJumps( left,top,width,height,centX,centY,reverse )
	self.platformWidth = math.max(1,math.min(6,math.floor(self.gap/8) * 2))
	self.platformHeight = 4
	local posY = self.maxY 
	local platConvert, sideConvert
	local leftPlat = not reverse
	lume.trace("Width: ", self.platformWidth)
	lume.trace("Height: ", self.platformHeight)
	self:addSidePlatforms(self.platformWidth, self.platformHeight,  reverse) 

	local middleWall = {{ x = 0, y = 0},
		{ x = self.platformWidth, y = 0},
		{ x = self.platformWidth, y = 2},
		{ x = 0, y = 2}}
	local posY = self.maxY
	local leftPlat = not reverse
	while (posY > self.minY) do
		local startX = self.leftWallPos + self.gap/2 - self.platformWidth/2 - 2
		platConvert = RoomUtils.offset(middleWall, startX, posY - 4)
		platConvert = RoomUtils.toAbsCoords(platConvert)
		self.room:addEnclosedArea(platConvert)

		self:addZone("ground",		startX,posY - 6, self.platformWidth,1)
		self:addZone("eyeLevel",	startX,posY - 8,self.platformWidth,1)
		if posY ~= self.maxY then
			self:addZone("ceiling",	startX,posY - 4,self.platformWidth,1)
		end
		posY = posY - 8
		leftPlat = not leftPlat
	end
end

return VtJumpsSolid