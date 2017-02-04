local Structure = require "roomgen.Structure"
local RoomUtils = require "roomgen.RoomUtils"
local StVert =  Class.create("StVert", Structure)

function StVert:init( room , evalArea,number, roomgen)
	Structure.init(self,room,evalArea, number, roomgen)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
	self.structType = "StVert"
	self.timeStamp = os.time()
	self.leftWallThickness = 4
	self.rightWallThickness = 4
	self.maxGap = 8
end

function StVert:makeStructure(left, top,width, height,centX,centY ,reverse )
	-- lume.trace("Vertical make structure")
	self.block = {left,top,width,height,centX,centY,reverse}
	self.minX = centX

	centX = centX + (2 - self.leftWallThickness)
	-- lume.trace("left: ", left, "top: ", top, "width: ",width, "height: ", height, "centX: ",centX)
	self:addLeftWall( left, top, width, height, centX, centY, reverse)
	self:addRightWall(left, top,width, height,centX,centY ,reverse, self.maxGap)
	self:addJumpThru(top + height, centY,centX + self.leftWallThickness,centX + self.leftWallThickness + self.gap)

	self.minY = top + 2
	self.maxY = top + height
	self.maxX = centX + self.gap
	self:fillPositions()
	-- self:fillBackground("wall")
end

function StVert:makeEnclosure( left, top,width, height,centX,centY ,reverse)
-- lume.trace("Making Jumps")
	self.maxGap = self.maxGap or 32
	self.block = {left,top,width,height,centX,centY,reverse}
	if reverse then
		self.minX = centX
	else
		self.minX = left + self.leftWallThickness + 4
	end
	self.minY = top + 2
	self.maxY = top + height

	centX = centX + (2 - self.leftWallThickness)
	self:addLeftWall( left, top, width, height, centX, centY, reverse)
	self:addRightWall(left, top,width, height,centX,centY ,reverse)
	self:fillPositions()
end

function StVert:addJumpThru( maxY, minY ,minX,maxX)
	local posY = minY 
	-- lume.trace(minX,maxX,minY,maxY)
	while (posY <= maxY) do
		local polyline = {{ x = minX, y = posY},
				{ x = maxX - 2, y = posY }}
		--util.print_table(polyline)
		self:addZone("ground",minX, posY - 2,maxX - minX - 4,1)
		local converted = RoomUtils.toAbsCoords(polyline)
		self.room:addSlopes( converted,false,nil,nil,true)
		posY = posY + 4
	end
end

function StVert:addLeftWall(left, top,width, height,leftWall,topLeft ,reverse )
	local botwall = {{ x = 0, y = 0 },
				{ x = self.leftWallThickness, y = 0 },
				{ x = self.leftWallThickness, y = (top + height) - topLeft},
				{ x = 0, y = (top + height) - topLeft}}
	local converted = RoomUtils.offset(botwall,leftWall,topLeft)
	converted = RoomUtils.toAbsCoords(converted)
	self.leftWallPos = leftWall + self.leftWallThickness
	self.minX = leftWall + 2
	self.height = top + height - topLeft
	--util.print_table(converted)

	self.room:addEnclosedArea(converted)
	self:addZone("leftSide", leftWall + 4, topLeft, 2, self.height)
	self:addZone("side", leftWall + 4, topLeft, 2, self.height)
end

function StVert:addRightWall(left, top,width, height,centX,centY ,reverse )
	self.gap = math.min((self.maxGap or 8),(left + width - centX) + 2 - self.rightWallThickness)
	local topWall = {{ x = 0, y = 0 },
					{ x = self.rightWallThickness, y = 0},
					{ x = self.rightWallThickness, y = (top + height) - centY},
					{ x = 0, y = (top + height) - centY}}
	local converted = RoomUtils.offset(topWall,centX + self.gap,centY)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)
	self.maxX = centX + self.gap
	self.width = self.maxX - self.minX
	self.rightWallPos = centX + self.gap
	self:addZone("rightSide", centX + self.gap - 2, centY, 2, self.height)
	self:addZone("side", centX + self.gap - 2, centY, 2, self.height)
end

function StVert:addSidePlatforms(platformWidth, platformHeight,  reverse) 
	local posY = self.maxY 
	local leftPlat = true
	local sideConvert, platConvert1
	local sideWall = {{ x = 0 , y = 0},
		{ x = platformWidth , y = 0},
		{ x = platformWidth , y = platformHeight},
		{ x = 0 , y = platformHeight}}
	local middleWall = {{ x = 0, y = 0},
		{ x = math.max(4,platformWidth), y = 0}}
	leftPlat = not reverse
	while (posY > self.minY) do
		local xStart
		if posY <= self.minY + 8 then
			if not reverse then
				xStart = self.leftWallPos
			else
				xStart = self.rightWallPos - self.platformWidth
			end
			sideConvert = RoomUtils.offset(sideWall, 	xStart, posY)
			platConvert1 = RoomUtils.offset(middleWall,	xStart, posY )
			self:addZone("ground",		xStart, posY - 2,platformWidth,1)
			self:addZone("solidGround",	xStart, posY - 2,platformWidth,1)
			self:addZone("eyeLevel",	xStart, posY - 4,platformWidth,1)
			sideConvert = RoomUtils.toAbsCoords(sideConvert)
			--self.room:addEnclosedArea(sideConvert)
			platConvert1 = RoomUtils.toAbsCoords(platConvert1)
			self.room:addSlopes(platConvert1,false,nil,nil,true)
			platConvert1 = RoomUtils.offset(platConvert1,0,-64)
			self.room:addSlopes(platConvert1,false,nil,nil,true)
			platConvert1 = RoomUtils.offset(platConvert1,0,-64)
			self.room:addSlopes(platConvert1,false,nil,nil,true)
			break
		end
		if not leftPlat then
			xStart = self.leftWallPos
		else
			xStart = self.rightWallPos - platformWidth
		end
		sideConvert = RoomUtils.offset(sideWall,xStart, posY - 8)
		sideConvert = RoomUtils.toAbsCoords(sideConvert)
		self.room:addEnclosedArea( sideConvert )
		self:addZone("ground",		xStart, posY - 10,platformWidth,1)
		self:addZone("solidGround",	xStart, posY - 10,platformWidth,1)
		self:addZone("eyeLevel",	xStart, posY - 12,platformWidth,1)
		if posY ~= self.maxY then
			self:addZone("ceiling",	xStart, posY + platformHeight + 2,platformWidth,1)
		end
		posY = posY - 8
		leftPlat = not leftPlat
	end
end
function StVert:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,-2,self.width,self.height)
end
return StVert