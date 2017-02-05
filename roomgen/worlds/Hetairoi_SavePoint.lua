local StPredef = require "roomgen.StPredef"
local RoomUtils = require "roomgen.RoomUtils"
local HtSavePoint = Class.create("HtSavePoint", StPredef)

function HtSavePoint:init( room , evalArea,number)
	StPredef.init(self,room,evalArea, number)
	self.width = 16
	lume.trace()
	self.height = 16
	self:addExit(16,1,"left")
	self:addExit(-15,1,"right")
end

function HtSavePoint:makeStructure( centX, centY )
	StPredef.makeStructure(self,centX,centY)
	-- self.room:addRectangleObj("lvl.ObjAnchor",self.centX - 1,self.centY - 2,2,2)
	local botwall = {{ x = 0, y = 0 },
				{ x = self.width, y = 0 },
				{ x = self.width, y = 4},
				{ x = 0, y = 4}}
	local converted = RoomUtils.offset(botwall,self.minX,self.minY + self.height - 2)
	converted = RoomUtils.toAbsCoords(converted)
	--util.print_table(converted)
	
	self.room:addEnclosedArea(converted)
	local newWall = {{ x = 0, y = 0 },
				{ x = 4, y = 0 },
				{ x = 4, y = 4},
				{ x = 0, y = 4}}
	converted = RoomUtils.offset(newWall,self.centX - 2,self.centY+2)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)

	local leftSlope = {{ x = 0, y = 0 },
				{ x = 4, y = 4}}
	converted = RoomUtils.offset(leftSlope,self.centX + 2,self.centY+2)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addSlopes(converted)
	local rightSlope = {{ x = 0, y = 4 },
				{ x = 4, y = 0}}
	converted = RoomUtils.offset(rightSlope,self.centX - 6,self.centY+2)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addSlopes(converted)
end

return HtSavePoint