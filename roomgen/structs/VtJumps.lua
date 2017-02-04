local StVert = require "roomgen.StVert"
local RoomUtils = require "roomgen.RoomUtils"
local VtJumps =  Class.create("VtJumps", StVert)

function VtJumps:init( room, evalArea, number,roomgen)
	StVert.init(self,room,evalArea, number,roomgen)
	self.structType = "VtJumps"
	self:setMinArea(1,0,1,0)
	self.maxGap = 32
end

function VtJumps:makeStructure(left, top,width, height,centX,centY ,reverse )
	self:makeEnclosure(left,top,width,height,centX,centY,reverse)
	self:addJumps(left, top,width, height,centX,centY ,reverse )
	self:fillBackground("wall")
end

function VtJumps:addJumps( left,top,width,height,centX,centY,reverse )
	self.platformWidth = math.max(1,math.min(6,math.floor(self.gap/8) * 2))
	self.platformHeight = 4
	local posY = self.maxY 
	local platConvert, sideConvert
	local leftPlat = not reverse
	self:addSidePlatforms(self.platformWidth, self.platformHeight,  reverse) 

	local middleWall = {{ x = 0, y = 0},
		{ x = self.platformWidth, y = 0}}
	local posY = self.maxY
	local leftPlat = not reverse
	while (posY > self.minY) do
		local startX = self.leftWallPos + self.gap/2 - self.platformWidth/2 - 2
		platConvert = RoomUtils.offset(middleWall, startX, posY - 4)
		platConvert = RoomUtils.toAbsCoords(platConvert)
		self.room:addSlopes(platConvert,false,nil,nil,true)

		self:addZone("ground",		startX,posY - 6, self.platformWidth,1)
		self:addZone("eyeLevel",	startX,posY - 8,self.platformWidth,1)
		if posY ~= self.maxY then
			self:addZone("ceiling",	startX,posY - 4,self.platformWidth,1)
		end
		posY = posY - 8
		leftPlat = not leftPlat
	end
end

return VtJumps