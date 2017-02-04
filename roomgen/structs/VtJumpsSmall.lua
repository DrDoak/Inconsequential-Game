local StVert = require "roomgen.StVert"
local RoomUtils = require "roomgen.RoomUtils"
local VtJumpsSmall =  Class.create("VtJumpsSmall", StVert)

function VtJumpsSmall:init( room, evalArea, number)
	StVert.init(self,room,evalArea, number)
	self.structType = "VtJumpsSmall"
	self:setMinArea(3,0,1,0)
	self.maxGap = 32
end

function VtJumpsSmall:makeStructure( left,top,width,height,centX,centY,reverse )
	self:makeEnclosure(left,top,width,height,centX,centY,reverse)
	self:addSmallJumps(left,top,width,height,centX,centY,reverse )
	-- self:fillBackground("wall")
end

function VtJumpsSmall:addSmallJumps( left,top,width,height,centX,centY,reverse )
	self.platformWidth = self.platfromWidth or math.max(2,math.min(6,math.floor(self.gap/8) * 2) / 2)
	self.platformWidth = math.ceil(self.platformWidth/2) * 2
	self.platformHeight = self.platfromHeight or 4
	local posY = self.maxY 
	local platConvert1, platConvert2
	self:addSidePlatforms(self.platformWidth * 2,self.platformHeight,reverse)
	local middleWall = {{ x = 0, y = 0},
		{ x = self.platformWidth, y = 0}}
	local posY = self.maxY
	local leftPlat = not reverse
	while (posY > self.minY) do
		local startY1, startY2
		if not leftPlat then
			startY1 = posY - 6
			startY2 = posY - 2
		else
			startY1 = posY - 2
			startY2 = posY - 6
		end
		platConvert1 = RoomUtils.offset(middleWall,self.leftWallPos + self.gap/2 - 4 - self.platformWidth,startY1)
		platConvert2 = RoomUtils.offset(middleWall,self.leftWallPos + self.gap/2,startY2)

		self:addZone("ground",self.leftWallPos + self.gap/2 - 4 - self.platformWidth,startY1 - 2,self.platformWidth,1)
		self:addZone("eyeLevel",self.leftWallPos + self.gap/2 - 4 - self.platformWidth,startY1 - 4,self.platformWidth,1)
		if posY ~= self.maxY then
			self:addZone("ceiling",self.leftWallPos + self.gap/2 - 4 - self.platformWidth,startY1,self.platformWidth,1)
		end

		self:addZone("ground",self.leftWallPos + self.gap/2,startY2 - 2,self.platformWidth,1)
		self:addZone("eyeLevel",self.leftWallPos + self.gap/2,startY2 - 4,self.platformWidth,1)
		if posY ~= self.maxY then
			self:addZone("ceiling",self.leftWallPos + self.gap/2,startY2,self.platformWidth,1)
		end
		platConvert1 = RoomUtils.toAbsCoords(platConvert1)
		self.room:addSlopes(platConvert1,false,nil,nil,true)
		platConvert2 = RoomUtils.toAbsCoords(platConvert2)
		self.room:addSlopes(platConvert2,false,nil,nil,true)
		posY = posY - 8
		leftPlat = not leftPlat
	end
end

return VtJumpsSmall