local Structure = require "roomgen.Structure"
local RoomUtils = require "roomgen.RoomUtils"
local StPredef =  Class.create("StPredef", Structure)

function StPredef:init( room , evalArea,number)
	Structure.init(self,room,evalArea, number)
	self.evalArea = evalArea
	self.structType = "StPredef"
	self.timeStamp = os.time()
	self.leftWallThickness = 4
	self.rightWallThickness = 4
	self.maxGap = 8
	self.width = 16
	self.height = 16
end

function StPredef:makeStructure( centX, centY )
	self.centX = centX
	self.centY = centY
	self:fillPositions()
	self.minX = centX - self.width/2
	self.minY = centY - self.height/2
end

function StPredef:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,0,-2,self.width,self.height)
end

function StPredef:addExit( relativeX,relativeY ,dir)
	if not self.exits then self.exits = {} end
	local newDict = {}
	newDict.x = relativeX
	newDict.y = relativeY
	newDict.dir = dir
	table.insert(self.exits,newDict)
end

function StPredef:fillPositions()
	local minX = math.ceil((self.centX -  self.width/2 + 1)/8)
	local minY = math.ceil((self.centY - self.height/2 + 1)/8)
	local maxX = math.max(minX,math.ceil((self.centX + self.width/2)/8))
	local maxY = math.max(minY,math.ceil((self.centY + self.height/2)/8))
	-- lume.trace("Preconvert: " , self.minX, "minX: ",minX, "maxX: ",maxX)
	-- lume.trace("minY: ",minY, "maxY: ",maxY)
	-- util.print_table(self.block)
	local x = minX
	local y = minY
	while (x <= maxX) do
		while (y <= maxY) do
			if self.evalArea[x] and self.evalArea[x][y] then
				if self.evalArea[x][y]["filled"] then
				end
				self.evalArea[x][y]["filled"] = true
				self.evalArea[x][y]["type"] = self.structType
				self.evalArea[x][y]["structNum"] = (self.structNum or -20)
			end
			y = y + 1
		end
		x = x + 1
		y = minY
	end
end

return StPredef