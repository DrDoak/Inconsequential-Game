local Structure = require "roomgen.Structure"
local RoomUtils = require "roomgen.RoomUtils"
local StStandard =  Class.create("StStandard", Structure)

function StStandard:init( room, evalArea, number, roomgen)
	Structure.init(self,room,evalArea, number, roomgen)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
	self.structType = "StStandard"
	self.bottomWallThickness = 2
	self.topWallThickness = 2
end

function StStandard:makeStructure(left, top,width, height,centX,centY ,reverse )
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

function StStandard:fillGround( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness - 1)
end

-- function StStandard:addBackWall( tileName,wallHeight,layer,probability,relativeX,relativeY,width,height )
-- 	self:fillArea(tileName,layer,probability,0,-(wallHeight or 4),self.width,(wallHeight or 4) )
-- end

function StStandard:addBackWall(tileName, wallHeight)
	lume.trace("addedBackWall")
	wallHeight = 4
	self.room:addRectangleObj("lvl.ObjVWall",self.x,self.y - wallHeight - 2,self.width,wallHeight,nil)
end



function StStandard:fill()
	self.minX = self.x --math.min(self.x, self.x + (self.width))
	self.maxX = self.x + self.width --math.max(self.x, self.x + (self.width))
	self.minY = self.y --self.groundLevel - self.gap - self.topWallThickness

	self.maxY = self.groundLevel
	self:fillPositions()
end

function StStandard:addBottomWall(left, top,width, height,centX,centY ,reverse )
	if not reverse then
		self.x = centX
		self.y = centY
		self.width = (left + width) - centX
	else
		self.x = left
		self.y = centY
		self.width = centX - left
	end
	self.groundLevel = self.groundLevel or self.y + height
	local botwall = {{ x = self.width, y = 0},
				{ x = 0, y = 0}}
	local converted = RoomUtils.offset(botwall,self.x,self.groundLevel)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addWallLink(converted)
end

function StStandard:addTopWall( left, top, width, height, centX, centY, reverse )
	if not reverse then
		self.x = centX
		self.y = centY
		self.width = (left + width) - centX
	else
		self.x = left
		self.y = centY
		self.width = centX - left
	end

	local upWall = {{ x = 0, y = 0}, { x = width, y = 0}}
	local converted = RoomUtils.offset(upWall,self.x,self.y)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addWallLink(converted)
end

function StStandard:addLeftWall( left, top, width, height, centX, centY, reverse )
	if not reverse then
		self.x = centX
		self.y = centY
		self.width = (left + width) - centX
	else
		self.x = left
		self.y = centY
		self.width = centX - left
	end

	local leftWall = {{ x = 0, y = 0}, { x = 0, y = self.height}}
	local converted = RoomUtils.offset(leftWall,self.x,self.y)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addWallLink(converted)
end

function StStandard:addRightWall( left, top, width, height, centX, centY, reverse )
	if not reverse then
		self.x = centX
		self.y = centY
		self.width = (left + width) - centX
	else
		self.x = left
		self.y = centY
		self.width = centX - left
	end

	local rightWall = {{ x = 0, y = 0}, { x = 0, y = self.height}}
	local converted = RoomUtils.offset(rightWall,self.x + width,self.y)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addWallLink(converted)
end

return StStandard