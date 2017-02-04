local StVert = require "roomgen.StVert"
local RoomUtils = require "roomgen.RoomUtils"
local VtJumpsAllThru =  Class.create("VtJumpsAllThru", StVert)

function VtJumpsAllThru:init( room, evalArea, number)
	StVert.init(self,room,evalArea, number)
	self.structType = "VtJumpsAllThru"
	self:setMinArea(1,0,1,0)
end

function VtJumpsAllThru:makeStructure(left, top,width, height,centX,centY ,reverse )
	
	self.platformWidth = math.min(6,math.floor(self.gap/8) * 2)
	local posY = self.maxY 
	local sideWall, middleWall
	local leftPlat = true
	if reverse then 
		leftPlat = false
	end
	while (posY > self.minY) do
		if posY <= self.minY + 8 then
			if not reverse then
				sideWall = {{ x = self.leftWallPos, y = posY},
					{ x = self.leftWallPos + self.platformWidth , y = posY}}
			else
				sideWall = {{ x = self.rightWallPos - self.platformWidth, y = posY},
					{ x = self.rightWallPos, y = posY}}
			end
			local converted = RoomUtils.toAbsCoords(sideWall)
			self.room:addSlopes( converted,false,nil,nil,true)
			converted = RoomUtils.offset(sideWall,0, -4)
			self.room:addSlopes(converted,false,nil,nil,true)
			break
		end
		if leftPlat then
			sideWall = {{ x = self.leftWallPos, y = posY},
				{ x = self.leftWallPos + self.platformWidth , y = posY}}
		else
			sideWall = {{ x = self.rightWallPos - self.platformWidth, y = posY},
				{ x = self.rightWallPos, y = posY }}
		end
		middleWall = {{x = self.leftWallPos + self.platformWidth, y = posY - 4},
			{ x = self.rightWallPos - self.platformWidth, y = posY - 4}}
		local converted = RoomUtils.toAbsCoords(sideWall)
		self.room:addSlopes( converted,false,nil,nil,true)
		converted = RoomUtils.toAbsCoords(middleWall)
		self.room:addSlopes( converted,false,nil,nil,true)
		posY = posY - 8
		leftPlat = not leftPlat
	end
	self:fillBackground("wall")
end

return VtJumpsAllThru