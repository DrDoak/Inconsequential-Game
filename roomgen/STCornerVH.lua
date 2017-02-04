local Structure = require "roomgen.Structure"
local RoomUtils = require "roomgen.RoomUtils"
local STCornerVH =  Class.create("STCornerVH", Structure)

function STCornerVH:init( room , evalArea, number,roomgen)
	Structure.init(self,room,evalArea, number, roomgen)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
	self.structType = "StCornerVH"
end

function STCornerVH:makeStructure(left, top,width, height,centX,centY ,reverse )
	self:addOuter(left, top,width, height,centX,centY ,reverse )
	self:addInner(left, top,width, height,centX,centY ,reverse)

	self.minX = self.x
	self.maxX = self.x 
	self.minY = self.y
	self.maxY = self.y 
	self.structType = "StCornerVH"
	self:fillPositions()
	--self:fillBackground("wall")
end

function STCornerVH:addOuter(left, top,width, height,centX,centY ,reverse )
	if reverse then
		self.x = centX 
		self.y = centY 
		self.width = (left + width) - centX
		self.corner = 6
		self.wall = 8
		self.outerEdge = 0
	else
		self.x = centX 
		self.y = centY 
		self.width = centX - left
		self.corner = 4
		self.wall = 0
		self.outerEdge = 10
	end
	local botwall = {{ x = self.corner, y = 2 },
				{ x = self.corner, y = 8},
				{ x = self.wall, y = 8},
				{ x = self.wall, y = -2},
				{ x = self.outerEdge, y = -2 },
				{ x = self.outerEdge, y = 2 }}
	local converted = RoomUtils.offset(botwall,self.x,self.y)
	--util.print_table(botwall)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)
	-- self:addZone("ceiling",self.x+math.min(self.wall,self.outerEdge), self.y+2,math.abs(self.wall - self.corner),1)
end

function STCornerVH:addInner(left, top,width, height,centX,centY ,reverse , maxGap)
	local topWall
	if not reverse then
		self.x = centX
		self.y = centY
		self.width = (left + width) - centX
		topWall = {{ x = 0, y = 0},
					{ x = 2, y = 0},
					{ x = 2, y = 2},
					{ x = 0, y = 2}}
	else
		self.x = centX
		self.y = centY
		self.width = centX - left
		topWall = {{ x = 6, y = 0},
					{ x = 8, y = 0},
					{ x = 8, y = 2},
					{ x = 6, y = 2}}
	end

	local converted = RoomUtils.offset(topWall,self.x,self.y)
	converted = RoomUtils.toAbsCoords(converted)
	self.room:addEnclosedArea(converted)
end

function STCornerVH:checkCollide(structure)
	return false
end
function STCornerVH:hasExit()
	return true
end
function STCornerVH:canHandleExists()
	return true
end

return STCornerVH