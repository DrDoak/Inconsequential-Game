local StStandard = require "roomgen.StStandard"
local RoomUtils = require "roomgen.RoomUtils"
local StHoriz =  Class.create("StHoriz", StStandard)

function StHoriz:init( room, evalArea, number, roomgen)
	StStandard.init(self,room,evalArea, number, roomgen)
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
	self.groundLevel = centY + 8
	-- self.maxGap = 12
	self:addBottomWall(left, top,width, height,centX,centY ,false )
	self:addTopWall(left, top,width, height,centX,centY ,false )
	self.height = (self.groundLevel) - top + self.bottomWallThickness
	-- self.block = {left,top,width,height,centX,centY,reverse}
	-- self:addGround(left, top,width, height,centX,centY ,reverse )


	-- self:addCeiling(left, top,width, height,centX,centY ,reverse )
	self:fill()
	--self:interSpaceObj( "en.EOBarrel", nil,"ground" , nil, 0.1)
end

function StHoriz:fill()
	self.minX = self.x --math.min(self.x, self.x + (self.width))
	self.maxX = self.x + self.width --math.max(self.x, self.x + (self.width))
	self.minY = self.y --self.groundLevel - self.gap - self.topWallThickness + 2
	self.maxY = self.groundLevel
	self:addZone("ground",self.minX,self.minY, self.width,self.groundLevel - self.minY)
	self:fillPositions()
end

function StHoriz:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness)
end

return StHoriz