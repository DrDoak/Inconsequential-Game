local Structure = require "roomgen.Structure"
local RoomUtils = require "roomgen.RoomUtils"
local StHoriz =  Class.create("StHoriz", Structure)

function StHoriz:init( room, evalArea, number, roomgen)
	Structure.init(self,room,evalArea, number, roomgen)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
	self.structType = "StHoriz"
	self.bottomWallThickness = 2
	self.topWallThickness = 2
	--lume.trace("Hiohioio")
end

function StHoriz:makeStructure(left, top,width, height,centX,centY ,reverse )
	--lume.trace("left:",left,"top",top,"width",width,"height",height,"centX",centX,"centY",centY)
	self.groundLevel = centY + 6
	self.maxGap = 12
	self.height = (self.groundLevel) - top + self.bottomWallThickness
	self.block = {left,top,width,height,centX,centY,reverse}
	self:addGround(left, top,width, height,centX,centY ,reverse )
	self:addCeiling(left, top,width, height,centX,centY ,reverse )
	self:fill()

	--self:interSpaceObj( "en.EOBarrel", nil,"ground" , nil, 0.1)
end

function StHoriz:fill()
	self.minX = self.x --math.min(self.x, self.x + (self.width))
	self.maxX = self.x + self.width --math.max(self.x, self.x + (self.width))
	self.minY = self.groundLevel - self.gap - self.topWallThickness + 2
	self.maxY = self.groundLevel + self.bottomWallThickness
	self:fillPositions()
end
function StHoriz:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness - 1)
end

function StHoriz:addGround(left, top,width, height,centX,centY ,reverse )
	if not reverse then
		self.x = centX
		self.y = centY
		self.width = (left + width) - centX
	else
		self.x = left
		self.y = centY
		self.width = centX - left
	end

	if self.height > 8 then
		self.topWallThickness = 4
	else
		self.topWallThickness = 2
	end
	self.gap = math.min((self.maxGap or 8),self.height - self.bottomWallThickness - self.topWallThickness)

	local botwall = {{ x = 0, y = 0 },
				{ x = self.width, y = 0 },
				{ x = self.width, y = self.bottomWallThickness},
				{ x = 0, y = self.bottomWallThickness}}
	local converted = RoomUtils.offset(botwall,self.x,self.groundLevel)
	converted = RoomUtils.toAbsCoords(converted)
	--util.print_table(converted)
	self.room:addEnclosedArea(converted)

	self:addZone("ground",self.x, self.y + 4,self.width,1)
	self:addZone("solidGround",self.x, self.y + 4,self.width,1)
	self:addZone("eyeLevel",self.x,self.y + 2, self.width,1)
	if self.gap > 4 then self:addZone("higherLevel",self.x,self.y, self.width,1) end

	-- lume.trace(self.x + self.width, self.groundLevel - self.gap, 1, self.gap)
	-- lume.trace(self.x, self.groundLevel - self.gap, 1, self.gap)
	self:addZone("leftSide", self.x, self.groundLevel - self.gap, 1, self.gap)
	self:addZone("rightSide", self.x + self.width - 2, self.groundLevel - self.gap, 1, self.gap)
	self:addZone("side", self.x, self.groundLevel - self.gap, 1, self.gap)
	self:addZone("side", self.x + self.width - 2, self.groundLevel - self.gap - 2, 1, self.gap)
end

function StHoriz:addHole(left, top,width, height,centX,centY ,reverse )
	if not reverse then
		self.x = centX
		self.y = centY
		self.width = (left + width) - centX
	else
		self.x = left
		self.y = centY
		self.width = centX - left
	end

	local botwall = {{ x = 0, y = 0 },
				{ x = self.width/2 - 2, y = 0 },
				{ x = self.width/2 - 2 , y = 2},
				{ x = 0, y = 2 }}
	local converted = RoomUtils.offset(botwall,self.x,self.y + 8)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)
	local converted = RoomUtils.offset(botwall,self.x,self.y + 6)
	self.groundLevel = self.y + 6
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)

	if self.height > 8 then
		self.topWallThickness = 4
	else
		self.topWallThickness = 2
	end
	self.gap = math.min((self.maxGap or 8),self.height - self.bottomWallThickness - self.topWallThickness)

	botwall = {{ x = self.width/2 + 2, y = 0 },
				{ x = self.width, y = 0 },
				{ x = self.width, y = 2},
				{ x = self.width/2 + 2, y = 2 }}
	local converted = RoomUtils.offset(botwall,self.x,self.y + 6)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)

	local polyline = {{ x = self.x + self.width/2 - 2, y = self.y + 6},
				{ x = self.x + self.width/2 + 2, y = self.y + 6 }}
	local converted = RoomUtils.toAbsCoords(polyline)
	self.room:addSlopes( converted,false,nil,nil,true)
	converted = RoomUtils.offset(converted,0,32)
	self.room:addSlopes(converted,false,nil,nil,true)

	self:addZone("ground",self.x, self.y + 4,self.width,1)
	self:addZone("solidGround",self.x, self.y + 4,self.width,1)
	self:addZone("eyeLevel",self.x,self.y + 2, self.width,1)
	if self.gap > 4 then self:addZone("higherLevel",self.x,self.y, self.width,1) end

	self:addZone("leftSide", self.x, self.groundLevel - self.gap, 1, self.gap)
	self:addZone("rightSide", self.x + self.width, self.groundLevel - self.gap, 1, self.gap)
	self:addZone("side", self.x, self.groundLevel - self.gap, 1, self.gap)
	self:addZone("side", self.x + self.width, self.groundLevel - self.gap, 1, self.gap)
end

function StHoriz:addCeiling(left, top,width, height,centX,centY ,reverse)
	--lume.trace(self.gap)
	local topWall = {{ x = 0, y = 0 },
					{ x = self.width, y = 0},
					{ x = self.width, y = self.topWallThickness},
					{ x = 0, y = self.topWallThickness}}
	local converted = RoomUtils.offset(topWall,self.x,self.groundLevel - self.gap - self.topWallThickness)
	--self.height = 2 + self.gap + self.topWallThickness
	converted = RoomUtils.toAbsCoords(converted)
	self:addZone("ceiling",self.x + 1, self.groundLevel - self.gap,self.width - 2,1)
	if self.gap > 4 then self:addZone("higherLevel",self.x,self.y, self.width,1) end

	self.room:addEnclosedArea(converted)
end

function StHoriz:addCeilHole(left, top,width, height,centX,centY ,reverse )
	local botwall = {{ x = 0, y = 0 },
				{ x = self.width/2 - 2, y = 0 },
				{ x = self.width/2 - 2 , y = 2},
				{ x = 0, y = 2 }}
	local converted = RoomUtils.offset(botwall,self.x,self.groundLevel)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)

	self.gap = self.height - self.bottomWallThickness - self.topWallThickness

	botwall = {{ x = self.width/2 + 2, y = 0 },
				{ x = self.width, y = 0 },
				{ x = self.width, y = self.topWallThickness},
				{ x = self.width/2 + 2, y = self.topWallThickness }}
	local converted = RoomUtils.offset(botwall,self.x,self.groundLevel - self.gap - self.topWallThickness)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)

	local polyline = {{ x = self.x + self.width/2 - 2, y = self.groundLevel - self.gap},
				{ x = self.x + self.width/2 + 2, y = self.groundLevel - self.gap}}
	local converted = RoomUtils.toAbsCoords(polyline)
	self.room:addSlopes( converted,false,nil,nil,true)
	converted = RoomUtils.offset(converted,0,-32)
	-- self.room:addSlopes(converted,false,nil,nil,true)

	-- botwall = {{ x = 0, y = 0 },
	-- 			{ x = 2, y = 0 },
	-- 			{ x = 2, y = self.topWallThickness},
	-- 			{ x = 0, y = self.topWallThickness}}
	-- local converted = RoomUtils.offset(botwall,self.x,self.groundLevel - self.gap - self.topWallThickness)
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addEnclosedArea(converted)

	-- self:addZone("ceiling",self.x, self.groundLevel - self.gap,self.width,1)
end

return StHoriz