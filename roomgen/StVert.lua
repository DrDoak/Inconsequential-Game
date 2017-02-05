local StStandard = require "roomgen.StStandard"
local RoomUtils = require "roomgen.RoomUtils"
local StVert =  Class.create("StVert", StStandard)

function StVert:init( room , evalArea,number, roomgen)
	StStandard.init(self,room,evalArea, number, roomgen)
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
	width = 8
	height = 8
	self:addLeftWall(left, top,width, height,centX,centY ,false )
	-- self:addLeftWall(left, top,width, height,centX,centY ,true )
	self:addRightWall(left, top,width, height,centX,centY ,false )

	self.width = width
	self.minX = centX
	self.minY = top
	self.maxY = top + height
	self.maxX = centX + self.width

	self.minX = self.x --math.min(self.x, self.x + (self.width))
	self.maxX = self.x + self.width --math.max(self.x, self.x + (self.width))
	self.minY = self.y --self.groundLevel - self.gap - self.topWallThickness + 2
	self.maxY = self.y + height
	self:addZone("ground",self.minX,self.minY, self.width,height)

	self:fillPositions()
end

function StVert:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,0,self.width,self.maxY - self.minY)
end

return StVert