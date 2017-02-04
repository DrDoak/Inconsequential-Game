local SubStruct = Class.new{}
local RoomUtils = require "roomgen.RoomUtils"

function SubStruct:init(struct, x,y,minX,maxX, minY,maxY)
	self.x = x
	self.y = y
	self.minX = minX
	self.maxX = maxX
	self.minY = minY
	self.maxY = maxY
	self.struct = struct
	self.room = struct.room
end

function SubStruct:makeStructure()
end

return SubStruct