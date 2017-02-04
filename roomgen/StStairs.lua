local Structure = require "roomgen.Structure"
local RoomUtils = require "roomgen.RoomUtils"
local StStairs =  Class.create("StStairs", Structure)

function StStairs:init( room )
	lume.trace()
	Structure.init(self,room)
	lume.trace(self.room)
	self.height = 8
	self.gap = 4
	self.width = 20
end

function StStairs:makeStructure()
	-- local slopeTest = {{ x = 0, y = 0 },
	-- 				{ x = 2, y = 2 },
	-- 				{ x = 6, y = 2},
	-- 				{ x = 10, y = 4},
	-- 				{ x = 12, y = 2},
	-- 				{ x = 14, y = 3},
	-- 				{ x = 16, y = 2}}
	-- local botSquare = {
	-- 				{ x = -4, y = 2},
	-- 				{ x = 8, y = 2},
	-- 				{ x = 8, y = 8},
	-- 				{ x = -4, y = 8}}
	-- local converted = RoomUtils.offset(botSquare,self.x,self.y + 2)
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addEnclosedArea(converted)

	-- local converted = RoomUtils.offset(botSquare,self.x,self.y - 4)
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addEnclosedArea(converted)

	-- local converted = RoomUtils.offset(botSquare,self.x + 12,self.y - 4)
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addEnclosedArea(converted)

	-- local converted = RoomUtils.offset(botSquare,self.x + 12,self.y + 2)
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addEnclosedArea(converted)

	
	local botSquare3 = {
					{ x = -4, y = 4},
					{ x = 12, y = 4},
					{ x = 12, y = 8},
					{ x = -4, y = 8}}
	local converted = RoomUtils.offset(botSquare3,self.x,self.y)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)

	-- local botSquare4 = {
	-- 				{ x = 12, y = 4},
	-- 				{ x = 24, y = 4},
	-- 				{ x = 24, y = 8},
	-- 				{ x = 12, y = 8}}
	-- local converted = RoomUtils.offset(botSquare4,self.x,self.y - 4)
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addEnclosedArea(converted)



	-- local slopeTest = {
	-- 				--{ x = -8, y = -6},
	-- 				{ x = -4, y = -2 },
	-- 				{ x = 4, y = 2 },
	-- 				{ x = 8, y = 0},
	-- 				{ x = 10, y = 0},
	-- 				{ x = 14, y = 4},
	-- 				{ x= 20, y = 4},
	-- 				{ x= 24, y = 0}
	-- 				}
	-- converted = RoomUtils.offset(slopeTest,self.x,self.y)
	-- converted = RoomUtils.toAbsCoords(converted)
	-- self.room:addSlopes(converted, true)
	self.x = 24
	self.y = 12
	self.width = 48
	self.height = 16
	self.gap = 4
	local r = 1
	if false then
		r = -1
	end
	-- lume.trace((self.height- self.gap)/2)
	-- lume.trace(self.height - (self.height- self.gap)/2)
	-- lume.trace(self.height)

	local outerCorner = {{ x = 0, y = self.height },
					{ x = self.width, y = self.height },
					{ x = self.width, y = self.height - (self.height- self.gap)/2},
					{ x = 0, y = self.height - (self.height- self.gap)/2 }}
	local converted = RoomUtils.offset(outerCorner,self.x,self.y)
	converted = RoomUtils.toAbsCoords(converted)

	self.room:addEnclosedArea(converted)
	local innerCorner = {{ x = 0, y = 0 },
					{ x = self.width, y = 0 },
					{ x = self.width, y = (self.height- self.gap)/2},
					{ x = 0, y = (self.height- self.gap)/2 }}
	converted = RoomUtils.offset(innerCorner,self.x,self.y)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)

	self.minX = math.min(self.x, self.x + (self.width))
	self.maxX = math.max(self.x, self.x + (self.width))
	self.minY = math.min(self.y, self.y + self.height)
	self.maxY = math.max(self.y, self.y + self.height)
	self:fillPositions()
end
return StStairs