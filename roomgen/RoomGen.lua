local RoomGen = Class.new {}
local Room = require "roomgen.Room"
local RoomUtils = require "roomgen.RoomUtils"

function RoomGen:init(wth,hgt,name,worldX,worldY,embelishFunct,objFunct,enemyFunct,blockFunct)
	self.room = Room(wth,hgt,name)
	self.room:setWorldXY( worldX,worldY )
	self.worldX = worldX
	self.worldY = worldY
	self.name = name
	self.width = wth
	self.height = hgt
	self.roomGenerated = false

	self.room:addTileSet("standin")
 	
 	self:setDefaultLookUp()
 	self:setTheme(require("roomgen.themes.THHetairoi"))
	self.initPlayerX = nil
	self.initPlayerY = nil
	self.numberOfExits = 0
	self.numStructs = 0
	self.enemyValue = 0
	self.structProbs = {}
	self.placedStructs = {}
	self.exits = {}
	self.paths = {}
	self.evalArea = RoomUtils.initialize2dTableArray( math.ceil(wth/8) ,math.ceil(hgt/8),{})
	self.corners = {}
	self.structList = {}

	self.embelishFunct = embelishFunct
	self.objFunct = objFunct
	self.enemyFunct = enemyFunct
	self.blockFunct = blockFunct
	self:setDefaultStructs()
end
function RoomGen:generate()
	lume.trace("Starting Room Generation for ", self.name)
	self:generateAllPaths()
 	self.exits = RoomUtils.identifyAll(self.evalArea,"exit")

	-- util.print_table(self.evalArea)
	self:identifyCornerStructs()

	self:addCorners()
	-- lume.trace("Corners added")
	--util.print_table(self.evalArea)

	-- lume.trace("starting to add corner structs")
	--self:addCornerStructs()
	-- lume.trace("starting to add extra structs")
	-- util.print_table(self.evalArea)

	self:addExtraStructs()
	-- self:fillEmpty()

	self:finishPaths()
	-- self.room:drawAllEdgeMaps()
	--self:finishEnemies()
	self.roomGenerated = true
	lume.trace("Room successfully generated")
end

function RoomGen:loadRoom( x,y )
	if not self.roomGenerated then
		self:generate()
	end
	Game.worldManager.worldX = self.worldX
	Game.worldManager.worldY = self.worldY
	Game.worldManager.evalArea = self.evalArea
	if x then
		self.room:loadRoom(x,y)
	else
		self.room:loadRoom(self.initPlayerX,self.initplayerY )
	end
end

function RoomGen:returnRoom( )
	if not self.roomGenerated then
		self:generate()
	end
	return self.room
end

-- Theming and Tile Functions---

function RoomGen:setType( maxType, types , numOfType,worldGen)
	self.type = maxType
	self.otherTypes = types
	self.numOfType = numOfType
	self.totalPathBlocks = 0
	-- util.print_table(self.otherTypes)
	for k,v in pairs(self.otherTypes) do
		self.totalPathBlocks = self.totalPathBlocks + v.count
	end
	-- lume.trace(self.totalPathBlocks)
	-- self.maxEnemyValue = 30 --(self.width * self.height) * (0.25 * numOfType)
	self.hardestEnemy = math.ceil(self.numOfType/3) * 10
	self.maxEnemyValue = self.totalPathBlocks * 2 * self.hardestEnemy
	worldGen.raelsLeft = worldGen.raelsLeft + self.totalPathBlocks
end

function RoomGen:setTheme( theme )
	self.theme = theme
	self.theme:setSubTheme("default",self.room)
end

function RoomGen:setSubTheme( subTheme )
	subTheme = subTheme or "default"
	self.theme:setSubTheme(subTheme, self.room)
end

function RoomGen:addNewTheme( tilesetID , width, height, themeTable)
	self.room:addTileSet(themeName,width,height)
	self.room:setThemeTable(themeTable, tilesetID)
end

function RoomGen:setDefaultLookUp( )
	local lookUpTable = {}
	-- lookUpTable["block"] = 1
	lookUpTable["wall"] = 5
	lookUpTable["fence"] = 10
	lookUpTable["slope"] = 2
	lookUpTable["slope2Bot"] = 11
	lookUpTable["slope2Top"] = 12

	lookUpTable["corner"] = 24
	lookUpTable["horizontal"] = 25
	lookUpTable["innerCorner"] = 26
	lookUpTable["vertical"] = 34
	lookUpTable["block"] = 35
	lookUpTable["jumpThru"] = 27
	lookUpTable["blockSingle"] = 5
	self.room:setThemeTable(lookUpTable,"standin")
end

function RoomGen:setBackground( bkg )
	self.room:addRoomProperty("backgroundScript",bkg)
end
------Struct List functions
function RoomGen:appendStructToList(structType, structName)
	local list = self.structList[structType]
	if not list then
		self.structList[structType] = {}
		list = self.structList[structType]
	end
	local newType = "roomgen." .. structName
	--lume.trace("appended to list: ", newType)
	table.insert(list,newType)
end

function RoomGen:replaceStructList( structType, list )
	local structs = self.structList[structType]
	structs = {}
	for i,v in ipairs(list) do
		table.insert(self.structList[structType],"roomgen." .. v)
	end
end
function RoomGen:setStructList( structList, structType)
	structType = structType or "default" 
	if structList then
		self.structList[structType] = structList
	else
		self.structList[structType] = self:generateDefaultStructList()
	end
end

function RoomGen:setDefaultStructs()	
	self:appendStructToList("horizontal","StHoriz")

	-- self:appendStructToList("vertical","structs.VtJumpsSolid") 
	-- self:appendStructToList("vertical","structs.VtDrops") 
	-- self:appendStructToList("vertical","structs.VtStairway") 
	-- self:appendStructToList("vertical","structs.VtJumpsSmall") 
	self:appendStructToList("vertical","StVert")
	-- self:appendStructToList("vertical","structs.VtJumps") 
	self:appendStructToList("cornerHV","StCornerHV") 
	self:appendStructToList("cornerVH","StCornerVH") 
	self:appendStructToList("slope","StSlope") 

	self:appendStructToList("cross","StCross") 
	self:appendStructToList("ceiling","StCeil") 
	self:appendStructToList("hole","StHole") 
	self:appendStructToList("stop","StStop") 

	self:appendStructToList("exitHoriz","ExHoriz") 
	self:appendStructToList("exitTop","ExTop") 
	self:appendStructToList("exitBottom","ExBottom") 
end

-- Generatl object placement functions

function RoomGen:addRandStruct( structType, x, y,width, height,centX,centY ,reverse ,params)
	local currList = self.structList[structType]
	-- lume.trace("--- of type: ", structType)
	local newStruct = false
	while (true) do 
		newStruct = self:randomStruct(currList)
		--lume.trace("Struct Added of type: -", structType, "- at x:", centX, "y:" , centY)
		if newStruct:canFit(x, y,width, height,centX,centY ,reverse) then
			self:addStruct(newStruct, x * 8 - 8, y * 8 - 8,(width * 8) , (height * 8) ,centX * 8 - 8,centY * 8 - 8,reverse ,params)
			break
		end
		-- lume.trace(newStruct:canFit(x, y,width, height,centX,centY ,reverse))
		-- lume.trace(currList)
		-- lume.trace(newStruct)
		util.deleteFromTable(currList,newStruct)
		-- lume.trace("No fit for type: " , structType, "remaining list")
		-- util.print_table(currList)
		if currList == {} then
			error("No object can fit for type: ", structType)
		end
	end
end

function RoomGen:randomStruct(structures)
	local probs = {}
	local totalWeight = 0
	--lume.trace("Adding random Structure")
	for i,v in ipairs(structures) do
		local structureEntry = {}
		structureEntry.weight = 10
		totalWeight = totalWeight + 10
		structureEntry.structPath = v
		table.insert(probs,structureEntry)
	end
	local randVal = Game.genRand:random(1,totalWeight)
	local totalRand = 0

	for i,v in pairs(probs) do
		totalRand = totalRand + v.weight
		if totalRand >= randVal then
			local newClass = require(v.structPath)
			self.numStructs = self.numStructs + 1
			local newStruct = newClass(self.room,self.evalArea, self.numStructs,self)
			--lume.trace(newStruct.structName)
			return newStruct
		end
	end
end

function RoomGen:addStruct( newStruct, x, y,width, height,centX,centY ,reverse , params)
	table.insert(self.placedStructs , newStruct)
	if params then
		for k,v in pairs(params) do
			newStruct[k] = v
		end
	end
	newStruct:makeStructure(x, y,width, height,centX,centY ,reverse)
	-- lume.trace("added struct of type: ", newStruct.structType)
	if self.embelishFunct then 
		self.embelishFunct(self,newStruct) end
	if self.objFunct then self.objFunct(self,newStruct) end
	if self.enemyFunct and newStruct.structType ~= "StFiller" then self.enemyFunct(self,newStruct) end
end

-- Specfic object placement functions ---
function RoomGen:addCorners() 
	local newCorners = self.corners
	for i,v in ipairs(self.corners) do
		local area = self:getAvaliableArea(v.x, v.y,self.evalArea)
		local reverse = false
		if v["filled"] or not area then
		else
			local corner = v["cornerType"]
			if v["left"] then
				reverse = true
			end
			if corner == "cornerHV" or corner == "cornerVH" then
				local foundDown = self:addSlopeDown(v.x,v.y, reverse)
				self:addSlopeUp(v.x,v.y, reverse,foundDown)
			end
			if not self.evalArea[v.x][v.y]["filled"] then
				self:addRandStruct(corner,area.left,area.top,area.width,area.height,area.centX,area.centY,reverse)
			end
		end
	end
end

function RoomGen:addSlopeDown(startX,startY , reverse)
	local initType = self.evalArea[startX][startY]["cornerType"]
	--lume.trace("-------------------- Slope Down Formation at " ,startX,startY)
	local cType = initType
	local curX = startX
	local curY = startY
	local minX = startX
	local maxX = startX
	local minY = startY
	local maxY = startY
	local first = true
	local slopeAreas = {}
	if cType == "cornerHV" then
		reverse = not reverse
	end
	local offsetX = 1
	if reverse then offsetX = -1 end

	-- Searching downwards
	local lastType = cType
	while true do
		--lume.trace("Current Coordinate: curX", curX, "curY",curY)
		cType = self.evalArea[curX][curY]["cornerType"]
		local v = self.evalArea[curX][curY]
		--lume.trace(cType, "offset: ", offsetX)
		if (cType == "cornerHV" or cType == "cornerVH") and (first or cType ~= lastType)  then
			local newPoint = {}
			newPoint.x = curX
			newPoint.y = curY
			if not RoomUtils.hasCoordinate(slopeAreas,newPoint) then
				table.insert(slopeAreas,newPoint)
			end
			if cType == "cornerHV" then  --and ((reverse and v["left"]) or (not reverse and v["right"]))then
				--lume.trace("minX:",minX,"maxX",maxX,"minY",minY,"maxY",maxY)
				minX = math.min(minX,(curX - offsetX))
				maxX = math.max(maxX,(curX - offsetX))
				maxY = curY 
				curX = curX - offsetX
				curY = curY
			elseif cType == "cornerVH" then --and ((reverse and v["right"]) or (not reverse and v["left"])) then
				curX = curX
				curY = curY + 1
			end
		else
			break
		end
		lastType = cType
		first = false
	end
	curX = startX
	curY = startY
	first = true
	cType = initType
	lastType = cType

	if (initType == "cornerVH" and table.getn(slopeAreas) > 1) or (initType == "cornerHV" and table.getn(slopeAreas) > 2) then
		--lume.trace("slopeAreas: ", table.getn(slopeAreas))
		--lume.trace("minX:",minX,"maxX",maxX,"minY",minY,"maxY",maxY, "reverse: ", reverse)
		for i,block in ipairs(slopeAreas) do
			if self.evalArea[block.x][block.y]["filled"] then
				lume.trace("slope blocked")
				return 
			end
		--self.evalArea[block.x][block.y]["filled"] = true
		end
		for i, block in ipairs(slopeAreas) do
			self.evalArea[block.x][block.y]["filled"] = true
			self.evalArea[block.x][block.y]["type"] = "StSlope"
			self.evalArea[block.x][block.y]["structNum"] = os.time()
		end
		--util.print_table(slopeAreas)
		if initType == "cornerHV" then
			self:addRandStruct("slope",minX,minY - 1,maxX -1,maxY-1,0,0,reverse)
		elseif initType == "cornerVH" then
			self:addRandStruct("slope",minX ,minY,maxX -1,maxY-1,0,0,reverse)
		end
		return true
	end
	return false
end

function RoomGen:addSlopeUp( startX,startY ,reverse, foundDown)
	local initType = self.evalArea[startX][startY]["cornerType"]
	--lume.trace("--------------------Slope Up Formation at " ,startX,startY)
	local cType = initType
	local curX = startX
	local curY = startY
	local minX = startX
	local maxX = startX
	local minY = startY
	local maxY = startY
	local first = true
	local numX = -1
	local lastType = cType
	local slopeAreas = {}
	if cType == "cornerHV" then
		-- -- lume.trace("reversing")
		-- reverse = not reverse
	end
	local offsetX = 1
	if reverse then offsetX = -1 end
	-- Searching Upwards
	while true do
		--lume.trace("Current Coordinate: curX", curX, "curY",curY)
		cType = self.evalArea[curX][curY]["cornerType"]
		local v = self.evalArea[curX][curY]
		--lume.trace(cType, "offset: ", offsetX)
		if (cType == "cornerHV" or cType == "cornerVH") and (first or cType ~= lastType)  then
			local newPoint = {}
			newPoint.x = curX
			newPoint.y = curY
			if not RoomUtils.hasCoordinate(slopeAreas,newPoint) then
				table.insert(slopeAreas,newPoint)
			end
			if cType == "cornerVH" then--and ((reverse and v["left"]) or (not reverse and v["right"])) then
				-- lume.trace("minX:",minX,"maxX",maxX,"minY",minY,"maxY",maxY)
				minX = math.min(minX,(curX + offsetX)) 
				maxX = math.max(maxX,(curX + offsetX))
				minY = math.max(curY ,minY)
				curX = curX + offsetX
				curY = curY
			elseif cType == "cornerHV" then--and ((reverse and v["right"]) or (not reverse and v["left"])) then
				numX = numX + 1
				curX = curX
				curY = curY - 1
				minX = math.min(minX,(curX + 6/8))
				maxX = math.max(maxX,(curX - 6/8))
				minY = math.max(curY ,maxY)
			end
		else
			break
		end
		lastType = cType
		first = false
	end

	if (foundDown and table.getn(slopeAreas) > 1) or (initType == "cornerVH" and table.getn(slopeAreas) > 2) or (initType == "cornerHV" and table.getn(slopeAreas) > 1) then
		--lume.trace("slopeAreas: ", table.getn(slopeAreas))
		-- lume.trace("minX:",minX,"maxX",maxX,"minY",minY,"maxY",maxY)
		for i,block in ipairs(slopeAreas) do
			if block.x ~= startX and block.y ~= startY and self.evalArea[block.x][block.y]["filled"] then
				-- lume.trace("slope blocked")
				return 
			end
		end
		for i, block in ipairs(slopeAreas) do
			self.evalArea[block.x][block.y]["filled"] = true
			self.evalArea[block.x][block.y]["type"] = "StSlope"
			self.evalArea[block.x][block.y]["structNum"] = os.time()
		end
		--util.print_table(slopeAreas)
		self:addRandStruct("slope",minX,minY-1,minX + numX,maxY-1,0,0,reverse)
	end
end

function RoomGen:identifyCornerStructs()
	-- local newCorners = self.corners
	-- Detect and add in Multiple Corner Structs
 	-- Detect and add in Single Corner Structs
	for i,outerTable in ipairs(self.evalArea) do
		for i2,v in ipairs(outerTable) do
			--local area = self:getAvaliableArea(v.x, v.y,self.evalArea)
			local reverse = false
			--lume.trace("adding corner at location: ", v.x," , ", v.y)
			--util.print_table(v)
			if v["corner"] or ((v["vertical"] or v["up"] or v["down"]) and (v["horizontal"] or v["left"] or v["right"])) then
				v["corner"] = true
			end
			if not v["corner"] or v["filled"] then
				--lume.trace("no area")
			elseif v["left"] then
				if v["right"] then
					if v["up"] then
						if v["down"] or v["vertical"] then --"Cross"
							v["cornerType"] = "cross"
						else -- ceiling
							v["cornerType"] = "ceiling"
						end
					elseif v["down"] then -- Hole
							v["cornerType"] = "hole"
					end
				elseif v["up"] then 
					if v["down"] then -- "elevator stop"
						v["cornerType"] = "stop"
					else -- Standard Corner
						v["cornerType"] = "cornerHV"
					end
				elseif v["down"] then -- Standard corner
					v["cornerType"] = "cornerVH"
				end
			elseif v["right"] then
				--reverse = true 
				if v["up"] then --
					if v["down"] then -- "elevator stop"
						v["cornerType"] = "stop"
					else -- Standard Corner
						v["cornerType"] = "cornerHV"
					end
				elseif v["down"] then -- Standard corner
					v["cornerType"] = "cornerVH"
				end
			end
			v["cornerType"] = v["cornerType"]
		end
	end
	self.corners = RoomUtils.identifyAll(self.evalArea,"corner")
end

function RoomGen:addCornerStructs()
	local newCorners = self.corners
	-- Detect and add in Multiple Corner Structs
 	-- Detect and add in Single Corner Structs
	for i,v in ipairs(self.corners) do
		local area = self:getAvaliableArea(v.x, v.y,self.evalArea)
		local reverse = false
		--lume.trace("adding corner at location: ", v.x," , ", v.y)
		--util.print_table(v)
		if v["filled"] then
		elseif not area then
			--lume.trace("no area")
		elseif v["left"] then
			if v["right"] then
				if v["up"] then
					if v["down"] then --"Cross"
						self:addRandStruct("cross",area.left,area.top,area.width,area.height,area.centX,area.centY,true)
					else -- ceiling
						self:addRandStruct("ceiling",area.left,area.top,area.width,area.height,area.centX,area.centY,true)
					end
				elseif v["down"] then -- Hole
					self:addRandStruct("hole",area.left,area.top,area.width,area.height,area.centX,area.centY,true)
				end
			elseif v["up"] then 
				if v["down"] then -- "elevator stop"
					self:addRandStruct("stop",area.left,area.top,area.width,area.height,area.centX,area.centY,true)
				else -- Standard Corner
					self:addRandStruct("cornerHV",area.left,area.top,area.width,area.height,area.centX,area.centY,true)
				end
			elseif v["down"] then -- Standard corner
				self:addRandStruct("cornerVH",area.left,area.top,area.width,area.height,area.centX,area.centY,true)
			end
		elseif v["right"] then
			reverse = true 
			if v["up"] then --
				if v["down"] then -- "elevator stop"
					self:addRandStruct("stop",area.left,area.top,area.width,area.height,area.centX,area.centY)
				else -- Standard Corner
					self:addRandStruct("cornerHV",area.left,area.top,area.width,area.height,area.centX,area.centY)
				end
			elseif v["down"] then -- Standard corner
				self:addRandStruct("cornerVH",area.left,area.top,area.width,area.height,area.centX,area.centY)
			end
		end
	end
end

function RoomGen:addExtraStructs()
	for k,v in ipairs(self.evalArea) do
		local newEntry = v
		for k2,v2 in ipairs(newEntry) do
			if v2["horizontal"] and not v2["filled"] then
				local area = self:getAvaliableArea(k, k2,self.evalArea)
				-- lume.trace("struct calculation before horizontal: ")
				-- util.print_table(area)
				self:addRandStruct("horizontal",area.left,area.top,area.width,area.height,area.centX,area.centY)
			elseif v2["vertical"] and not v2["filled"] then
				local area = self:getAvaliableArea(k, k2,self.evalArea)
				-- lume.trace("struct calculation before horizontal: ")
				-- util.print_table(area)
				self:addRandStruct("vertical",area.left,area.top,area.width,area.height,area.centX,area.centY)
			end
		end
	end
end

function RoomGen:fillEmpty()
	local newTable = {}
	for k,v in pairs(self.evalArea) do
		for k2,v2 in ipairs(v) do
			if not v2["filled"] then
				local newClass = require("roomgen/StFiller")
				local newStruct = newClass(self.room,self.evalArea)
				--lume.trace("Added Filler at loc X: ",k,"Y: ",k2)
				self:addStruct(newStruct, k * 8 - 8, k2 * 8 - 8 ,8,8, k * 8 - 8, k2 * 8 - 8 )
				--lume.trace('Struct Added of type: filler')
			end
		end
	end
	self.corners = newTable
end

-- Exit handling functions ---
function RoomGen:addPreviousExit( dir , previousRoom, prevX, prevY,worldX,worldY)
	local x,y
	local positions = {}
	-- lume.trace("Adding Previous Exit")
	-- lume.trace("previous room : " , previousRoom, "X: ", prevX, "Y: ", prevY)
	-- lume.trace("Other room worldX: ", worldX, "myWorldX: ", self.worldX, "GoalY: ", prevX)
	-- lume.trace("Other room worldY: ", worldY, "myWorldY: ", self.worldY, "GoalY: ", prevY)
	if dir == "left" then
		x = math.ceil(self.width/8)
		y = math.ceil(prevY/8) - ( self.worldY - worldY )* 4
		--y = math.ceil(Game.genRand:random(9,self.height - 9)/8)
	elseif dir == "right" then
		x = 1
		y = math.ceil(prevY/8) - ( self.worldY - worldY )* 4
		lume.trace("Right, with coords: ", x, y)
		--y = math.ceil(Game.genRand:random(9,self.height - 9)/8)
	elseif dir == "up" then
		x = math.ceil(prevX/8) - ( self.worldX - worldX)* 4
		--x = math.ceil(Game.genRand:random(9,self.width - 9)/8)
		y = math.ceil(self.height/8)
	elseif dir == "down" then
		x = math.ceil(prevX/8) - ( self.worldX - worldX)* 4
		--x = math.ceil(Game.genRand:random(9,self.width - 9)/8)
		y = 1
	end
	-- lume.trace("Previous exit being created")
	if dir == "down" then
		prevY = prevY - 4
	end
	local positions = util.deepcopy(self:addExit(x * 8,y * 8, previousRoom, prevX, prevY, dir))
	positions.x = positions.x - 4
	lume.trace(dir)
	if dir == "up" then
		positions.y = positions.y - 8
	else
		positions.y = positions.y - 4
	end
	--util.print_table(self.paths)
	--lume.trace("New Position for changer: ",positions.x,positions.y)
	return positions
end

function RoomGen:addExit( x , y , goal, goalX, goalY, direction, pathName)
	self.numberOfExits = self.numberOfExits + 1
	pathName = pathName or "default"
	if not self.initPlayerX then
		self.initPlayerX = x
		self.initPlayerY = y
	end
	local evalX = math.ceil(x/8)
	local evalY = math.ceil(y/8)
	if not self.evalArea[evalX] or not self.evalArea[evalX][evalY] then
		lume.trace("Position does not exist: " , evalX, evalY)
		lume.trace("Width: " , self.width, "Height: ", self.height)
		error(" Attempting to access exit out of location")
	end
	if self.evalArea[evalX][evalY]["filled"] then
		--lume.trace("exit already exists, quitting")
		return false
	end
	if (direction == "left" or direction == "right") then
		if (evalY == math.ceil(self.height/8) and ( evalX == 1 or evalX == math.ceil(self.width/8))) then
			evalY = evalY - 1
		end
		if (evalY == 1 and ( evalX == 1 or evalX == math.ceil(self.width/8))) then
			evalY = evalY + 1
		end
	end
	if (direction == "up" or direction == "down") then
		if (evalX == math.ceil(self.width/8) and ( evalY == 1 or evalY == math.ceil(self.height/8))) then
			evalX = evalX - 1
		end
		if (evalX == 1 and ( evalY == 1 or evalY == math.ceil(self.height/8))) then
			evalX = evalX + 1
		end
	end
	self.evalArea[evalX][evalY]["exit"] = true

	local newPoint = {}
	newPoint.x = evalX * 8
	newPoint.y = evalY * 8
	-- local newString = "Terminal " .. self.numberOfExits
	-- self.exits[newString] = newPoint
	if not self.paths[pathName] then self.paths[pathName] = {} end
	-- lume.trace("adding Exit at unmodified: " , newPoint.x, newPoint.y)
	table.insert(self.paths[pathName],newPoint)
	-- util.print_table(self.paths)

	local area = self:getAvaliableArea(evalX, evalY,self.evalArea)
	-- lume.trace("adding exit at location: ", evalX," , ", evalY)
		--util.print_table(v)
	--lume.trace("Exit Goal: " , goal)
	local props
	if not area then
		lume.trace("no area")
	elseif evalX == 1 then
		props = {nextRoom = goal, newX = goalX, newY = goalY, prevX = evalX * 8 - 4, prevY = evalY * 8 - 4}
		self:addRandStruct("exitHoriz",area.left,area.top,area.width,area.height,area.centX,area.centY, false,props)
	elseif evalX == math.ceil(self.width/8) then
		props =  {nextRoom = goal, newX = goalX, newY = goalY, prevX = evalX * 8 - 4, prevY = evalY * 8 - 4}
		self:addRandStruct("exitHoriz",area.left,area.top,area.width,area.height,area.centX,area.centY,true, props)
	elseif evalY == 1 then
		props =  {nextRoom = goal, newX = goalX, newY = goalY, prevX = evalX * 8 - 4, prevY = evalY * 8 - 4}
		self:addRandStruct("exitTop",area.left,area.top,area.width,area.height,area.centX,area.centY,true, props)
	elseif evalY == math.ceil(self.height/8) then
		props =  {nextRoom = goal, newX = goalX, newY = goalY, prevX = evalX * 8 - 4, prevY = evalY * 8 - 4}
		self:addRandStruct("exitBottom",area.left,area.top,area.width,area.height,area.centX,area.centY,true, props)
	else
		error("invalid location for exit")
	end
	return newPoint
end

----Path Generation Functions----
function RoomGen:finishPaths()
	for k,v in pairs(self.evalArea) do
		local newEntry = v
		for k2,v2 in pairs(newEntry) do
			if (v2["horizontal"] or v2["vertical"]) and not v2["filled"] then

			end
		end
	end
end

function RoomGen:tileBlocked( x,y, centX,centY,dir)
	if not self.evalArea[x] or not self.evalArea[x][y] then
		lume.trace("x: ", x , "y: ", y)
		lume.trace("width: ", self.width / 8)
		lume.trace("height: ", self.height / 8)
		-- util.print_table(self.evalArea)
		error("Attempting to access a tile that does not exist")
	end
	if self.evalArea[x][y]["filled"] or 
		(x ~= centX and y ~= centY and (self.evalArea[x][y]["corner"] or self.evalArea[x][y]["exit"])) or 
		(self.evalArea[x][y]["horizontal"] and y ~= centY) or 
		(self.evalArea[x][y]["vertical"] and x ~= centX) then
		-- lume.trace("Tile BLocked")
		-- lume.trace(dir)
		-- lume.trace(x)
		-- lume.trace(y)
		return true
	end
	return false
end

function RoomGen:getAvaliableArea(x,y,table)
	--lume.trace("calculating avaliable area")
	--util.print_table(self.evalArea)
	--lume.trace("initial x: ", x, "Y: ", y)
	--util.print_table(self.evalArea[x][y]) 
	if self:tileBlocked(x,y,x,y,'up') then
	--	lume.trace("initial blocked")
		return false
	end
	local top = y - 1
	local found = {}
	local bottom = y + 1
	local left = x - 1
	local right = x + 1
	local dir = 'up'
	local curX = x - 1
	local curY = y
	if not self.evalArea[curX] or  self:tileBlocked( curX,curY, x,y,dir) then
		found['left'] = true
		left = curX
		curX = curX + 1
	end
	while (true) do
		--lume.trace("dir:", dir, "x: ", curX, "Y: ", curY, "right: ", right)
		if dir == 'down'then
			if not self.evalArea[curX][curY+1] then
				found['bottom'] = true
				bottom = curY + 1
			elseif  self:tileBlocked( curX,curY + 1, x,y,dir) then
				if ( curY + 1 == bottom) then
					found['bottom'] = true
					bottom = curY + 1
					dir = "left"
				else
					found['right'] = true
					-- lume.trace("Found right")
					-- lume.trace(right)
					right = curX
					curX = curX - 1
					-- lume.trace("Setting new right " , right)
				end
			else
				curY = curY + 1
			end
			if (found['bottom'] and curY + 1 == bottom) or curY == bottom then
				bottom = curY + 1
				dir = "left"
			end
		elseif dir == 'up' then
			if not self.evalArea[curX][curY-1] then
				found['up'] = true
				top = curY - 1
				-- lume.trace("new Top: ", top)
			elseif self:tileBlocked( curX,curY - 1, x,y,dir) then
				if (curY - 1 == top) then
					found['up'] = true
					top = curY - 1
					-- lume.trace("new Top: ", top)
					dir = "right"
				else
					found['left'] = true
					left = curX
					curX = curX + 1
				end
			else
				curY = curY - 1
			end
			if (found['up'] and curY - 1 == top) or curY == top then
				top = curY - 1
				-- lume.trace("new Top: ", top)
				dir = "right"
			end
		elseif dir == 'left' then
			if not self.evalArea[curX-1] then
				found['left'] = true
				left = curX - 1
				-- lume.trace("setting Left: ", left)
			elseif self:tileBlocked( curX - 1,curY, x,y,dir) then
				if (curX - 1 == left) then
					found['left'] = true
					left = curX - 1
					dir = "up"
				else
					found['bottom'] = true
					bottom = curY
					curY = curY - 1
				end
			else
				curX = curX - 1
			end
			if (found['left'] and curX - 1 == left) or curX == left then
				left = curX - 1
				dir = "up"
				-- lume.trace("setting Left: ", left)
			end
		elseif dir == 'right' then
			if not self.evalArea[curX+1] then
				found['right'] = true
				right = curX + 1
				-- lume.trace("Setting new right " , right)
			elseif self:tileBlocked( curX + 1,curY, x,y,dir) then
				-- lume.trace("right", right)
				-- lume.trace("up", top)
				-- lume.trace("found right", found['right'])
				-- lume.trace(curX + 1)
				if (curX + 1 == right ) then
					found['right'] = true
					right = curX + 1
					dir = "down"
					--lume.trace("Setting new right " , right)
				else
					found['up'] = true
					top = curY
					-- lume.trace("new Top: ", top)
					curY = curY + 1
				end
			else
				curX = curX + 1
			end
			if (found['right'] and curX + 1 == right) or curX == right then
				right = curX + 1
				dir = "down"
			end
		end
		if found['left'] and found['right'] and found['up'] and found['bottom'] then
			break
		end
	end
	local area = {}
	-- lume.trace("right: " ,right)
	-- lume.trace("left: ", left)
	area.width = right - left  - 1
	area.height = bottom - top - 1
	area.left = left + 1
	area.top = top + 1
	area.endX = left + area.width 
	area.endY = top + area.height 
	area.centX = x
	area.centY = y
	--lume.trace("finished calculating area")
	--util.print_table(area)
	return area
end


function RoomGen:generateBorder(exitList)
	local evalExits = {}
	for i,v in ipairs(exitList) do
		local newExit = {}
		newExit.x = math.ceil(v.x/8)
		newExit.y = math.ceil(v.y/8)
		table.insert(evalExits,newExit)
	end
	local tb = {}
	for i=1,math.ceil(self.width/8) do
		local top = {}
		top.y = 1
		top.x = i
		if not RoomUtils.hasCoordinate(evalExits,top) then
			table.insert(tb,top)
		end
		local bot = {}
		bot.x = i
		bot.y = math.ceil(self.height/8)
		if not RoomUtils.hasCoordinate(evalExits,bot) then
			table.insert(tb,bot)
		end
	end
	for i=1,math.ceil(self.height/8) do
		local top = {}
		top.y = i
		top.x = 1
		if not RoomUtils.hasCoordinate(evalExits,top) then
			table.insert(tb,top)
		end
		local bot = {}
		bot.y = i
		bot.x = math.ceil(self.width/8)
		if not RoomUtils.hasCoordinate(evalExits,bot) then
			table.insert(tb,bot)
		end
	end
	return tb
end

function RoomGen:generateAllPaths( )
	lume.trace("generating the following paths: ")
	util.print_table(self.paths)
	for i,v in pairs(self.paths) do
		--util.print_table(v)
		self:generatePaths(v)
	end
end

function RoomGen:generatePaths(exitList)
	local exitsMet = 1
	local testStart = {}
	--lume.trace("generating path with number of exit: " , table.getn(exitList))
	if table.getn(exitList) == 1 then
		lume.trace("Only one exit")
		util.print_table(exitList)
		return
	end
	local border = self:generateBorder(exitList)

	 -- util.print_table(exitList[1])
	testStart = RoomUtils.tileToEval(exitList[1])
	-- lume.trace('adding initial path:')	
	-- util.print_table(testStart)

	--util.print_table(testStart)
	local testEnd = {}
	--util.print_table(self.exits)
	testEnd = RoomUtils.tileToEval(RoomUtils.furthest(exitList[1],exitList))
	-- util.print_table(testEnd)
	
	-- lume.trace("Test End: ")
	-- util.print_table(testEnd)

	if testEnd.x == testStart.x and testEnd.y == testStart.y then
		lume.trace("Entrance and exit are the same, quitting")
		return
	end
	local original = util.deepcopy(self.evalArea)
	local result = RoomUtils.randomPath(testStart,testEnd,original,math.ceil(self.width/8),math.ceil(self.height/8),border,self.blockFunct)[1]
	RoomUtils.combineTables(self.evalArea,result)
	--util.print_table(self.evalArea)
	-- lume.trace("initial path completed")

	local i = 2
	while i <= table.getn(exitList) do
		-- lume.trace("generating additional path: ", i)
		self.corners = RoomUtils.identifyAll(self.evalArea,"corner")
		local nextEnd = exitList[i]
		local closestCorner = self:closestPoint(nextEnd,exitList)
		testStart = RoomUtils.tileToEval(nextEnd)
		testEnd = RoomUtils.tileToEval(closestCorner)
		if testEnd.x == testStart.x and testEnd.y == testStart.y then
			lume.trace("Entrance and exit are the same, skipping")
		else
			-- lume.trace('adding additional path')
			-- lume.trace("Start:")
			-- util.print_table(testEnd)
			-- lume.trace("Exit: ")
			-- util.print_table(testStart)
			--util.print_table(self.evalArea)
			border = self:generateBorder(exitList)
			local result = RoomUtils.randomPath(testStart,testEnd,original,math.ceil(self.width/8),math.ceil(self.height/8),border, self.blockFunct)[1]
			RoomUtils.combineTables(self.evalArea ,result)
		end
		--util.print_table(self.evalArea)
		i = i + 1
	end
end

function RoomGen:closestPoint( point ,corners)
	local minDist = 999999
	local furthesPoint = {}
	--lume.trace("Goal: X: ", point.x, " Y: ",point.y)
	for i,v in ipairs(corners) do
		local newEntry = v
		local newCost = RoomUtils.heuristic_cost_estimate(point,newEntry)
		--lume.trace(newCost)
		--lume.trace('minDist: ', minDist)
		if newCost < minDist and newCost > 0 then
			minDist = newCost
			furthesPoint = v
			--lume.trace('new min set to :', minDist, " X: ",furthesPoint.x, " Y: ", furthesPoint.y)
		end
	end
	return furthesPoint
end

---------------------- ENemy management

function RoomGen:finishEnemies()
	local numIt = 0
	while self.enemyValue < self.maxEnemyValue  or numIt > 2 do
		for i,v in ipairs(self.placedStructs) do
			if v.enemyValue == 0 then
				self.enemyFunct(self,v)
			end
		end
		numIt = numIt + 1
	end
end

function RoomGen:setHardestEnemy( value )
	self.hardestEnemy = value
end

function RoomGen:randomEnemy(enemyList, struct)
	local probs = {}
	local totalWeight = 1
	-- lume.trace("Adding random Enemy")
	-- lume.trace(self.hardestEnemy)
	-- lume.trace(#struct.zones["ground"])
	for i,v in ipairs(enemyList) do
		-- lume.trace((self.hardestEnemy >= v.value))
		-- util.print_table(v)
		-- lume.trace(v.value)
		-- lume.trace((not v.minArea or v.minArea > #struct.zones["ground"]))
		if ((self.hardestEnemy or 100) >= v.value) and (not v.minArea or v.minArea > #struct.zones["ground"]) then
			local entry = {}
			entry.weight = v.weight or 10
			totalWeight = totalWeight + v.probabilityWeight
			-- lume.trace("adding weight: ", v.probabilityWeight, "to make: ", totalWeight)
			entry.value = v.value or 10
			entry.enemies = v.enemies
			table.insert(probs,entry)
		end
	end
	-- lume.trace("total weight is" , totalWeight)
	local randVal = Game.genRand:random(1,totalWeight)
	local totalRand = 0
	-- lume.trace(totalWeight, "val: ", randVal)

	for i,v in pairs(probs) do
		totalRand = totalRand + v.weight
		-- lume.trace(v.weight)
		if totalRand >= randVal then
			-- lume.trace("Placing enemy of type: ")
			struct:placeEnemyGroup(v.enemies,v.value)
			return
		end
	end
end
-- function RoomGen:createBoundingBox()
-- 	local wallVerts = {{ x = 0, y = 0 },
--             			{ x = self.width, y = 0 },
--             			{ x = self.width, y = self.height },
--             			{ x = 0, y = self.height },
--             			{ x = 0, y = 0 }}
--     wallVerts = RoomUtils.toAbsCoords(wallVerts)
--     self.room:addWall(0,0,wallVerts,false)
-- end

-- function RoomGen:fillBackground( tileName )
-- 	local tn = tileName or "bkg"
-- 	local x = 0
-- 	local y = 0
-- 	while (x < self.width) do 
-- 		while (y < self.height) do 
-- 			self.room:setTile("bkg1",x,y,tn)
-- 			y = y + 2
-- 		end
-- 		y = 0
-- 		x = x + 2
-- 	end
-- end
-- function RoomGen:createObject()
-- 	local newObj = util.create("roomgen/".. objectName, self.room)
-- 	newObj:setLocation(4,10)
-- 	newObj:make()
-- 	Game:add(newObj)
-- end
return RoomGen