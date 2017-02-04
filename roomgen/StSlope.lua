local Structure = require "roomgen.Structure"
local StHoriz = require "roomgen.StHoriz"
local RoomUtils = require "roomgen.RoomUtils"
local StSlope =  Class.create("StSlope", StHoriz)

function StSlope:init( room , evalArea)
	Structure.init(self,room)
	self.height = 8
	self.gap = 4
	self.width = 20
	self.evalArea = evalArea
	self:setMinArea(0,0,0,0)
end

function StSlope:makeStructure(minX, minY,maxX, maxY,centX,centY ,reverse )
	self.x = minX 
	self.y = minY
	local converted
	local slope
	self.minX = self.x
	self.minY = self.y
	self.maxX = maxX
	self.maxY = maxY
	self.reverse = reverse
	-- lume.trace(maxX-minX)
	--lume.trace("Slope added")
	if self.reverse then
		for hPos=1,(maxX-minX)/8 do
			--lume.trace(hPos)
			slope = {{x=0,y=0},{x=8,y=8}}
			converted = RoomUtils.offset(slope,self.x+(hPos-1)*8, self.y+6+(hPos-1)*8)
			-- lume.trace("slope X: ",self.x+8+(hPos-1)*8, "Slope Y :" , self.y+6-(hPos-1)*8)
			converted = RoomUtils.toAbsCoords(converted)
			self.room:addSlopes( converted,true,nil,nil)
		end
	else
		--slope = {{x=0,y=maxY - minY},{x=(maxX-minX),y=0}}
		-- lume.trace((maxX-minX)/8)
		for hPos=1,(maxX-minX)/8 do
			--lume.trace(hPos)
			slope = {{x=0,y=8},{x=8,y=0}}
			converted = RoomUtils.offset(slope,self.x+8+(hPos-1)*8, self.y+6-(hPos-1)*8)
			-- lume.trace("slope X: ",self.x+8+(hPos-1)*8, "Slope Y :" , self.y+6-(hPos-1)*8, "hpos", hPos)
			converted = RoomUtils.toAbsCoords(converted)
			self.room:addSlopes( converted,true,nil,nil)
		end
	end
end 

function StSlope:fillBackground( tileName,layer,probability )
	lume.trace("Filling background of slope")
	--self:fillArea(tileName,layer,probability,0,0,self.width,self.topWallThickness + self.gap + self.bottomWallThickness )

	if self.reverse then
		for hPos=1,(self.maxX-self.x)/8 do
			-- lume.trace("Self.x: ", self.x , "self.minX: ", self.minX)
			-- lume.trace("Self.y: ", self.y , "self.minY: ", self.minY)
			--lume.trace(hPos)
			-- local slope = {{x=0,y=0},{x=8,y=8}}
			-- converted = RoomUtils.offset(slope,self.x+(hPos-1)*8, self.y+6+(hPos-1)*8)
			-- lume.trace("slope X: ",8 + (hPos-1)*8, "Slope Y :" , 8+(hPos-1)*8)
			self:fillArea(tileName,layer,probability,  8 + (hPos-1)*8 - 8,8+(hPos-1)*8 - 8,8,8)
			self:fillArea(tileName,layer,probability,  8 + (hPos-1)*8 - 8, 8+(hPos-1)*8,8,8)
		end
	else
		--slope = {{x=0,y=maxY - minY},{x=(maxX-minX),y=0}}
		-- lume.trace((maxX-minX)/8)
		for hPos=1,(self.maxX-self.x)/8 do
			--lume.trace(hPos)
			-- slope = {{x=0,y=8},{x=8,y=0}}
			-- converted = RoomUtils.offset(slope,self.x+8+(hPos-1)*8, self.y+6-(hPos-1)*8)
			-- lume.trace("slope X: ",self.x+8+(hPos-1)*8, "Slope Y :" , self.y+6-(hPos-1)*8, "hpos", hPos)
			--lume.trace("slope X: ",self.x+8+(hPos-1)*8, "Slope Y :" , self.y+8-(hPos-1)*8)
			self:fillArea(tileName,layer,probability, 8 + (hPos-1)*8, 8-(hPos-1)*8 - 8,8,8)	
			self:fillArea(tileName,layer,probability, 8 + (hPos-1)*8, 8-(hPos-1)*8,8,8)
		end
	end
end
function StSlope:addJumpThru( maxY, minY ,minX,maxX)
	local posY = minY 
	while (posY <= maxY) do
		local polyline = {{ x = minX, y = posY},
				{ x = maxX, y = posY }}
		--util.print_table(polyline)
		local converted = RoomUtils.toAbsCoords(polyline)
		self.room:addSlopes( converted,false,nil,nil,true)
		posY = posY + 4
	end
end

function StSlope:canFit(left, top,width, height,centX,centY ,reverse)
	return true
end
-- function StSlope:addLeftWall(left, top,width, height,centX,centY ,reverse )
-- 	-- if width <= 8 then
-- 	-- 	self.leftWallThickness = 2
-- 	-- else
-- 	-- 	self.leftWallThickness = 4
-- 	-- end
-- 	local botwall = {{ x = 0, y = 0 },
-- 				{ x = self.leftWallThickness, y = 0 },
-- 				{ x = self.leftWallThickness, y = (top + height) - centY},
-- 				{ x = 0, y = (top + height) - centY}}
-- 	local converted = RoomUtils.offset(botwall,centX,centY)
-- 	converted = RoomUtils.toAbsCoords(converted)
-- 	--util.print_table(converted)

-- 	self.room:addEnclosedArea(converted)
-- end

-- function StSlope:addRightWall(left, top,width, height,centX,centY ,reverse , maxGap)
-- 	-- if width <= 8 then
-- 	-- 	self.rightWallThickness = 2
-- 	-- else
-- 	-- 	self.rightWallThickness = 4
-- 	-- end
-- 	self.gap = math.min((maxGap or 8),width - 2 - self.rightWallThickness)
-- 	local topWall = {{ x = 0, y = 0 },
-- 					{ x = self.rightWallThickness, y = 0},
-- 					{ x = self.rightWallThickness, y = (top + height) - centY},
-- 					{ x = 0, y = (top + height) - centY}}
-- 	local converted = RoomUtils.offset(topWall,centX + self.gap,centY)
-- 	converted = RoomUtils.toAbsCoords(converted)
-- 	self.room:addEnclosedArea(converted)
-- 	self.maxX = centX + self.gap

-- end

return StSlope