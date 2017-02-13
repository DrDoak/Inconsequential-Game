local Structure = Class.new {}
local RoomUtils = require "roomgen.RoomUtils"

--- General Construction ---
function Structure:init( room, evalArea,number,roomgen)
	self.room = room
	self.x = 0
	self.y = 0
	self.enemyValue = 0
	self.objects = {}
	self.evalArea = evalArea
	self.zones = {}

	self.roomgen = roomgen
	self.structNum = number
	self.block = {{ x = 0, y = 0},
		{ x = 2 , y = 0},
		{ x = 2 , y = 2},
		{ x = 0 , y = 2}}
end

function Structure:setSize(wth,hgt)
	self.width = wth
	self.height = hgt
end

function Structure:setLocation( x , y )
	self.x = x
	self.y = y
end

function Structure:makeFully( )
	self:makeStructure()
	self.room:drawAllEdgeMaps()
end

--- Parameters ----
function Structure:addParameter(param,initValue)
end
function Structure:setParameter( param,value )
end

--- Weight and Selection---

function Structure:calculateWeight()
	return 10
end

--- Compatibility Tests ---
function Structure:setMinArea(minLeft,minRight,minUp,minDown)
	self.minLeft = minLeft
	self.minRight = minRight
	self.minUp = minUp
	self.minDown = minDown
	self.minRequiredWidth = minLeft + minRight
	self.minRequiredHeight = minUp + minDown
end

function Structure:canFit(left, top,width, height,centX,centY ,reverse)
	local maxLeft = centX - left + 1
	local maxUp = centY - top + 1
	local maxRight = left + width - centX + 1
	local maxDown = top + height - centY  + 1

	local maxWidth = width
	if self.structType == "VtJumpsSolid" then
		-- lume.trace("_--------------------_")
		-- lume.trace("left: " , left)
		-- lume.trace("top: " , top)
		-- lume.trace("width: " , width)
		-- lume.trace("height: " , height)
		-- lume.trace("centX: " , centX)
		-- lume.trace("centX: " , centY)

		-- lume.trace("maxLeft",maxLeft)
		-- lume.trace("minLeft: " , self.minLeft)
		-- lume.trace("maxRight: ",maxRight)
		-- lume.trace("minRight: " , self.minRight)
		-- lume.trace("maxUp",maxUp)
		-- lume.trace("minUp: " , self.minUp)
	end
	if (maxLeft >= self.minLeft) and (maxUp >= self.minUp) 
		and (maxRight >= self.minRight)
		and (maxDown >=self. minDown) then
		self.maxLeft = maxLeft
		self.maxUp = maxUp
		self.maxRight = maxRight
		self.maxDown = maxDown
		self.centX = centX
		self.centY = centY
		--lume.trace("Can Fit")
		-- lume.trace("Structure: ", self.structType, "Can fit")
		return true
	end
	-- lume.trace("Struct of type: " , self.structType, " cannot fit.")
	return false
end

function Structure:makeStructure(x, y,width, height,centX,centY ,reverse )
end

function Structure:fillPositions()
	--lume.trace("filling type: ", self.structType)
	local minX = math.ceil((self.minX + 1)/8)
	local minY = math.ceil((self.minY + 1)/8)
	local maxX = math.max(minX,math.ceil((self.maxX)/8))
	local maxY = math.max(minY,math.ceil((self.maxY)/8))
	-- lume.trace("Preconvert: " , self.minX, "minX: ",minX, "maxX: ",maxX)
	-- lume.trace("minY: ",minY, "maxY: ",maxY)
	-- util.print_table(self.block)
	local x = minX
	local y = minY
	while (x <= maxX) do
		while (y <= maxY) do
			if self.evalArea[x] and self.evalArea[x][y] then
				if self.evalArea[x][y]["filled"] then
					-- lume.trace("----conflict-----")
					-- lume.trace("CurrentStruct: " ,self.structType)
					-- lume.trace("Other  Struct: " ,self.evalArea[x][y]["type"])
					-- util.print_table(self.evalArea[x][y])
					-- util.print_table(self.block)
					-- --left, top, width, height,centX,centY ,reverse 
					-- lume.trace("X: ", x ,"Y: ",y)
					-- lume.trace("MyX: ", self.x, "MyY: ", self.y, "myWidth: ", self.width, "myHeight: ", self.height)
					-- lume.trace("evX: ", math.ceil(self.x/8), "MyY: ", math.ceil(self.y/8), "myWidth: ", math.ceil(self.width/8), "myHeight: ", math.ceil(self.height/8))
					-- lume.trace("minX: ",math.ceil((self.minX + 1)/8), "maxX: ",math.ceil((self.maxX + 1)/8))
					-- lume.trace("minX: ",math.ceil((self.minY + 1)/8), "maxX: ",math.ceil((self.maxY + 1)/8))
					-- --error("filling area already filled")
				end
				self.evalArea[x][y]["filled"] = true
				self.evalArea[x][y]["type"] = self.structType
				self.evalArea[x][y]["structNum"] = (self.structNum or -20)
				--lume.trace("===1=X: ", x,"Y: ",y)
			end
			y = y + 1
		end
		x = x + 1
		y = minY
	end
end

-- Object Placement --

function Structure:placeEnemy( enemyType, params,zone, value)
	self.enemyValue = self.enemyValue + value
	self.roomgen.enemyValue = self.roomgen.enemyValue + value
	self:placeObj(enemyType,params,zone)
end

function Structure:placeEnemyGroup( enemyTable, totalWeight )
	--lume.trace("Placing enemy in struct: ", self.structType)
	self.enemyValue = self.enemyValue + totalWeight
	-- lume.trace(self.structType)
	self.roomgen.enemyValue = self.roomgen.enemyValue + totalWeight
	for i,v in ipairs(enemyTable) do
		self:placeEnemy("en." .. v.eType,v.params,(v.zone or "ground"),0)
	end
end
-- Embellishment --

function Structure:addObject( objType, x, y, params )
	self.room:addRectangleObj(objType,x - 1,y - 1,2,2,params)
	local ObjReference = {}
	ObjReference.x = x
	ObjReference.y = y
	ObjReference.objType = objType
	table.insert(self.objects,ObjReference)
end

function Structure:addStruct( objType, x, y, params )
	local newObj = require("roomgen.substructs." .. objType)
	local newEnt = newObj(self, x,y,self.minX,self.maxX,self.minY,self.maxY,params)
	if type(params) == "table" then
		for k,v in pairs(params) do
			newEnt[k] = v
		end
	end
	newEnt:makeStructure()
	table.insert(self.objects,newEnt)
end

function Structure:distanceToObj( objectType)
	-- body
end

function Structure:addZone( zoneType, leftX, topY, width, height )
	if not self.zones[zoneType] then self.zones[zoneType] = {} end
	local i = leftX
	local j = topY
	while (i <= (leftX + width - 1)) do
		while (j <= (topY + height - 1)) do 
			local newCoords = {}
			newCoords.x = i
			newCoords.y = j
			--lume.trace(i, j)
			table.insert(self.zones[zoneType], newCoords)
			j = j + 2
		end
		j = topY
		i = i + 2
	end
end

function Structure:getNumZone( zoneType )
	return #self.zones[zoneType]
end

function Structure:interSpaceStruct( structType, params,zoneType , minSpace, probabiltyPerSquare, maxObjects, noOverlap)
	local numObjects = 0
	minSpace = minSpace or 0
	maxObjects = maxObjects or 99999
	if not self.zones[zoneType] then 
		if self.structType ~= "StFiller" then
			-- lume.trace("Zone Type does not exist: ", zoneType, " in ", self.structType)
		end
		return
	end
	-- Game.genRand:randomseed(os.time())
	local sinceLast = minSpace
	for i,v in ipairs(self.zones[zoneType]) do
		if sinceLast >= minSpace and Game.genRand:random() < probabiltyPerSquare then
			sinceLast = 0
			v.structType = true
			v.filled = true
			self:addStruct(structType,v.x,v.y,params)
			numObjects = numObjects + 1
			if numObjects >= maxObjects then
				break
			end
		end
		sinceLast = sinceLast + 1
	end
end

function Structure:placeObj( objType,params,zoneType,maxObjects )
	maxObjects = maxObjects or 1
	local curr = 0
	if not self.zones[zoneType] then
		lume.trace("NO zones of type: ", zoneType, "in struct: ", self.structType)
		return
	end
	while (curr < maxObjects) do
		local i = Game.genRand:random(1,#self.zones[zoneType])
		local v = self.zones[zoneType][i]
		self:addObject(objType,v.x,v.y,params)
		curr = curr + 1
	end
end

function Structure:interSpaceObj( objType, params,zoneType , minSpace, probabiltyPerSquare, maxObjects , noOverlap )
	local numObjects = 0
	maxObjects = maxObjects or 99999
	if not self.zones[zoneType] then 
		lume.trace("Zone Type does not exist: ", zoneType)
		return
	end
	-- Game.genRand:randomseed(os.time())
	lume.trace(structType)
	minSpace = minSpace or 0
	local sinceLast = minSpace 
	for i,v in ipairs(self.zones[zoneType]) do
		if sinceLast >= 0  and Game.genRand:random() < probabiltyPerSquare then
			sinceLast = 0
			v.objType = objType
			v.filled = true
			self:addObject(objType,v.x,v.y,params)
			numObjects = numObjects + 1
			if numObjects >= maxObjects then
				break
			end
		end
		sinceLast = sinceLast + 1
	end
end

function Structure:interSpaceTile( tileName, layer,zoneType , minSpace, probabiltyPerSquare, maxTiles ,flipX,flipY)
	local numTiles = 0
	minSpace = minSpace or 0
	maxTiles = maxTiles or 99999
	if not self.zones[zoneType] then 
		if self.structType ~= "StFiller" then
			-- lume.trace("Zone Type does not exist: ", zoneType, " in ", self.structType)
		end
		return
	end
	-- Game.genRand:randomseed(os.time())
	local sinceLast = minSpace
	for i,v in ipairs(self.zones[zoneType]) do
		if sinceLast >= minSpace and Game.genRand:random() < probabiltyPerSquare then
			sinceLast = 0
			v.tileName = true
			v.filled = true
			self.room:setTile(layer,v.x,v.y,tileName,flipX,flipY)
			numTiles = numTiles + 1
			if numTiles >= maxTiles then
				break
			end
		end
		sinceLast = sinceLast + 1
	end
end

function Structure:fillBackground( tileName,layer,probability,relativeX,relativeY,width,height )
	self:fillArea(tileName,layer,probability,relativeX,relativeY,width,height )
end

function Structure:fillArea(tileName,layer,probability, relativeX,relativeY,width,height)
	layer = layer or "bkg1"
	probability = probability or 1.0
	if relativeX then
		-- relativeX = relativeX / 16
		-- relativeX = relativeY / 16
		-- lume.trace("Filling background with relativeX:", relativeX)
		-- lume.trace("roomWidth: ", self.room.width)
		-- lume.trace("MinX: ", self.minX)
		-- lume.trace("width: ", width)
		relativeX = relativeX + self.minX
		relativeY = relativeY + self.minY
		local i = relativeX
		local j = relativeY
		while (i <= relativeX + width - 2) do
			while (j <= relativeY + height - 2) do 
				if Game.genRand:random() < probability then
					-- lume.trace("Drawing tile at", i, j)
					self.room:setTile(layer,i,j,tileName)
				end
				j = j + 2
			end
			j = relativeY
			i = i + 2
		end
	else
		for x= math.ceil(self.minX/8),math.ceil(self.maxX/8) do
			for y=math.ceil(self.minY/8),math.ceil(self.maxY/8) do
				local i = 0
				local j = 0
				while(i < 8) do 
					while (j < 8) do 
						self.room:setTile(layer,(x*8)+i,(y*8)+j,tileName)
						j = j + 2
					end
					j = 0
					i = i + 2
				end
			end
		end
	end
end
return Structure