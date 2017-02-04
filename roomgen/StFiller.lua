local Structure = require "roomgen.Structure"
local RoomUtils = require "roomgen.RoomUtils"
local StFiller =  Class.create("StFiller", Structure)

function StFiller:init( room , evalArea,number)
	Structure.init(self,room,evalArea,number)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
end

function StFiller:makeStructure(left, top,width, height,centX,centY ,reverse )
	self:addSquare( left, top, width, height, centX, centY, reverse)

	self.minY = centY
	self.maxY = centY
	self.maxX = centX
	self.minX = centX
	self.structType = "StFiller"
	self:fillPositions()
end

function StFiller:addSquare(left, top,width, height,centX,centY ,reverse )
	local wall = {{ x = 0, y = 0 },
				{ x = 8, y = 0 },
				{ x = 8, y = 8},
				{ x = 0, y = 8}}
	local converted = RoomUtils.offset(wall,centX,centY)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)
end

return StFiller