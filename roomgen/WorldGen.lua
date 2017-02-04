local RoomGen = require "roomgen.RoomGen"
local RoomGenPredef = require "roomgen.RoomGenPredef"
local RoomUtils = require "roomgen.RoomUtils"
local Gamestate = require "hump.gamestate"
local WorldGen = Class.new {}

function WorldGen:init(width,height) 
	self.worldWidth = width or 32
	self.worldHeight = height or 32
	self.goalList = {}
	self.roomsGenerated = self.roomsGenerated or 1
	self.evalArea = RoomUtils.initialize2dTableArray( self.worldWidth ,self.worldHeight,{})
	--self:setDefaultRooms()--slope generation is not good
	-- 1470453570 -- ton of problems, crashes on new room     
	--1471728623 crash  -- 1471566834 good vertical testing
	local seed = 1471566834 -- 1471728623 --os.time()-- --os.time() --1471039884 --os.time() --1470607460 --os.time() --os.time() --
	Game.genRand = love.math.newRandomGenerator( 12321 )
	lume.trace("seed: ", seed)   
	self.namesList = {}   
	self.startPos = {}
	self.startPos.x = 0
	self.startPos.y = 0  
	self.raelsGenerated = 0 
	self.raelsLeft = 0                                             
end

function WorldGen:setGenerationFunction( generationFunction )
	self.generateFunct = generationFunction
end

function WorldGen:setObjGenerationFunction( genFunct )
	self.objFunct = genFunct
end

function WorldGen:setEnemyFunction( genFunct )
	self.enemyFunct = genFunct
end

function WorldGen:setEmbelishmentFunction( genFunct )
	self.embelishFunct = genFunct
end

function WorldGen:setPreGenFunct( genFunct )
	self.pregenFunc = genFunct
end

function WorldGen:setBlockGenFunct(genFunct)
	self.blockFunc = genFunct
end

function WorldGen:quickStart()
	local newTable = {}
	newTable = util.persistence.load("assets/randRooms/WorldEval.lua")
	self.evalArea = newTable
	Game.WorldManager.evalArea = self.evalArea
	local newTable2 = {}
	newTable2 = util.persistence.load("assets/randRooms/WorldGenInfo.lua")
	util.print_table(newTable2)
	lume.trace("Newtable: " , newTable2.initRoom, newTable2.initX, newTable2.initY)
	local player = Game.player
	local x,y = player.body:getPosition()
	local newX = newTable2.initX and tonumber(newTable2.initX)* 16 or x
	local newY = newTable2.initY and tonumber(newTable2.initY) * 16 or y
	player:setPosition( newX, newY )

	local newInitRoom = {}
	newInitRoom = util.persistence.load(newTable2.initRoom)
	--lume.trace(newTable)
	lume.trace("NEwWorldX: ", newTable2.worldX, "newWorldY.", newTable2.worldY)
	Game.WorldManager.worldX = newTable2.worldX
	Game.WorldManager.worldY = newTable2.worldY
	Game:loadRoom(newInitRoom)
end

function WorldGen:saveWorldInfo()
	-- lume.trace("Saving World Info")
	util.persistence.store("assets/randRooms/WorldEval.lua",self.evalArea)
	local initRoomInfo = {}
	initRoomInfo.initRoom = "assets/initRooms/" .. self.initRoom.name .. ".lua"
	initRoomInfo.initX = self.startPos.x
	initRoomInfo.initY = self.startPos.y
	initRoomInfo.worldX = self.initRoom.worldX
	initRoomInfo.worldY = self.initRoom.worldY
	util.persistence.store("assets/randRooms/WorldGenInfo.lua",initRoomInfo)
end

function WorldGen:start()
	if true then
		if not self.generated then
			local function default(worldgen)
				lume.trace("Running default funct") 
				worldgen:addInitialGoals(3)
				worldgen:generatePaths(worldgen.goalList)
				lume.trace("=====================Adding initial room")
				worldgen.initRoom = RoomGen(64,64, "StartingRoom",worldgen.worldWidth/2,worldgen.worldWidth/2)

				worldgen:fillArea(worldgen.worldWidth/2,worldgen.worldHeight/2,2,2,"StartingRoom",worldgen.worldWidth/2,worldgen.worldHeight/2)
				worldgen.startPos = worldgen:addOtherRoomExits(worldgen.initRoom)
			end
			local generateFunct = self.generateFunct or default
			self.generated = true
			generateFunct(self)
			self:saveWorldInfo()
		end

		self.roomsGenerated = 2
		-- lume.trace("starting Player at position: ", self.startPos.x, self.startPos.y)
		self.initRoom:loadRoom(self.startPos.x,self.startPos.y)

		self:saveCurrentRoom("assets/initRooms/" .. Game.roomname .. ".lua")
	else
		self:quickStart()
	end
	Game.WorldManager:respawnFromDeath(Game.player)
	--util.print_table(self.evalArea)
end

function WorldGen:addPreDefinedRoom( xSize,ySize,name, posX,posY ,templateRoom)
	local room
	if templateRoom then
		room = RoomGenPredef(xSize,ySize,name,posX,posY,self.embelishFunct, self.objFunct, self.enemyFunct,self.blockFunc,templateRoom)
	else
		room = RoomGen(xSize,ySize,name,posX,posY,self.embelishFunct, self.objFunct, self.enemyFunct,self.blockFunc)
	end
	room.preGen = self.pregenFunc
	if self.pregenFunc then self.pregenFunc(room) end
	self:fillArea(posX,posY,xSize/32,ySize/32,name,posX,posY)
	local startPos = self:addOtherRoomExits(room)
	return {room,startPos}
end

function WorldGen:addPlaceHolderRoom( xSize,ySize,name, posX,posY ,templateRoom)
	name = "pd-" .. templateRoom
	self:fillArea(posX,posY,xSize/32,ySize/32,name,posX,posY, {width=(xSize/32),height=(ySize/32),startX=posX,startY=posY})
end

function WorldGen:addRandomGoalInRange(x,y,xRange,yRange, goalName,PresetRoom)
	local numTrials = 0
	local randX, randY
	while true do
		randX = math.random(math.max(1,x - xRange),math.min(self.worldWidth - 1, x + xRange))
		randY = math.random(math.max(1,y - yRange),math.min(self.worldHeight - 1, y + yRange))
		numTrials = numTrials + 1
		if not self.evalArea[randX][randY]["goal"] then
			break
		elseif numTrials > 100 then
			error("Number of tests exceeded limit, no goal could be placed")
		end
	end
	-- if self.randX == self. then
	-- 	randX = randX - 1
	-- elseif self.randY == self.height then
	-- 	randY = randY - 1
	-- end

	return self:addGoal(randX,randY,goalName,PresetRoom)
end

function WorldGen:addGoal( x,y,goalName,PresetRoom,id )
	local newPoint = {}
	newPoint.x = x
	newPoint.y = y
	if PresetRoom then
		self:addPlaceHolderRoom(64,64,goalName,x,y,PresetRoom)
	end
	-- lume.trace("Goal created at point: X: ", newPoint.x, "Y: ", newPoint.y)
	table.insert(self.goalList,newPoint)
	self.evalArea[x][y]["goal"] = goalName or true
	self.evalArea[x][y]["goalID"] = id
	return newPoint
end

function WorldGen:addInteraction( x,y,intType )
	if not self.evalArea[x][y].interactions then
		self.evalArea[x][y].interactions = {}
	end
	table.insert(self.evalArea[x][y].interactions,intType)
end

function WorldGen:addInitialGoals(numberOfGoals)
	local wall = Game.genRand:random(1,4)
	local finalpoint
	for i=1,numberOfGoals do
		local dir = Game.genRand:random(1,2)
		local offset = Game.genRand:random(self.worldWidth/2 - 3,self.worldWidth/2 - 1)
		local x = self.worldWidth/2
		if dir == 1 then
			x = x + offset
		else
			x = x - offset
		end
		local y = self.worldHeight/2
		offset = Game.genRand:random(self.worldHeight/2 - 3,self.worldHeight/2 - 1)
		dir = Game.genRand:random(1,2)
		if dir == 1 then
			y = y + offset
		else
			y = y - offset
		end
		local newPoint = {}
		newPoint.x = x
		newPoint.y = y
		table.insert(self.goalList,newPoint)
		self.evalArea[x][y]["goal"] = true
	end
end

function WorldGen:generatePaths(exitList)

	local exitsMet = 1
	local testStart = {}
	testStart.x = self.worldWidth/2
	testStart.y = self.worldHeight/2
	local testEnd = {}
	--util.print_table(self.exits)
	--lume.trace('Creating World Paths')
	testEnd = RoomUtils.furthest(testStart,exitList)
	--lume.trace('adding initial path')
	local original = util.deepcopy(self.evalArea)
	local result = RoomUtils.randomPath(testStart,testEnd,original,self.worldWidth,self.worldHeight)[1]
	RoomUtils.combineTables(self.evalArea , result)
	--lume.trace('first path found')
	-- util.print_table(exitList)

	local i = 2
	while i <= table.getn(exitList) do
		--lume.trace("Current it: ", i)
		self.corners = RoomUtils.identifyAll(self.evalArea,"corner")
		local nextEnd = exitList[i]
		local closestCorner = self:closestCorner(nextEnd,exitList)
		testStart = nextEnd
		testEnd = closestCorner

		--lume.trace('adding additional path')
		--util.print_table(self.evalArea)
		-- util.print_table(testStart)
		-- util.print_table(testEnd)
		local result = RoomUtils.randomPath(testStart,testEnd,original,self.worldWidth,self.worldHeight)[1]
		RoomUtils.combineTables(self.evalArea , result)
		--util.print_table(self.evalArea)
		i = i + 1
		--lume.trace("finished path")
	end
	self.corners = RoomUtils.identifyAll(self.evalArea,"corner")
end

function WorldGen:generatePath( testStart,testEnd, pathType)
	local empty = RoomUtils.initialize2dTableArray( self.worldWidth ,self.worldHeight,{})
	local result = RoomUtils.randomPath(testStart,testEnd,empty,self.worldWidth,self.worldHeight,nil,nil,pathType)
	local currX = testStart.x
	local currY = testStart.y
	local distance = result[2]
	result = result[1]
	local distCovered = 0
	local lastDir = "none"
	-- while (currX ~= testEnd.x and currY ~= testEnd.y) do
	-- 	local currentNode = result[currX][currY]	
	-- 	distCovered = distCovered + 1
	-- 	if not currentNode.inPath then --or (currentNode.pathType and currentNode.pathType ~= pathType and distCovered > (distance/2)) then
	-- 		break
	-- 	end
	-- 	result[currX][currY].pathType = pathType

	-- 	if currentNode["vertical"] then
	-- 		if lastDir == "down" or (result[currX][currY+ 1] and result[currX][currY+ 1].inPath) then
	-- 			currY = currY + 1
	-- 			lastDir = "down"
	-- 		elseif lastDir == "up" or (result[currX][currY-1] and result[currX][currY- 1].inPath) then
	-- 			currY = currY - 1
	-- 			lastDir = "up"
	-- 		end
	-- 	end
	-- 	if currentNode["horizontal"] then
	-- 		if lastDir == "right" or ( result[currX+1][currY] and result[currX+1][currY].inPath )then
	-- 			currX = currX + 1
	-- 			lastDir = "right"
	-- 		elseif lastDir == "left" or (result[currX-1][currY] and result[currX-1][currY].inPath ) then
	-- 			currX = currX - 1
	-- 			lastDir = "left"
	-- 		end
	-- 	end
	-- 	if currentNode["corner"] then
	-- 		if currentNode["up"] and lastDir ~= "down" then
	-- 			currY = currY - 1
	-- 			lastDir = "up"
	-- 		elseif currentNode["down"] and lastDir ~= "up" then
	-- 			currY = currY + 1
	-- 			lastDir = "down"
	-- 		elseif currentNode["left"] and lastDir ~= "right" then
	-- 			currX = currX - 1
	-- 			lastDir = "left"
	-- 		elseif currentNode["right"] and lastDir ~= "left" then
	-- 			currX = currX + 1
	-- 			lastDir = "right"
	-- 		end
	-- 	end
	-- end
	RoomUtils.combineTables(self.evalArea,result)
end

function WorldGen:closestCorner( point ,corners)
	local minDist = 999999
	local furthestPoint = {}
	--lume.trace("Goal: X: ", point.x, " Y: ",point.y)
	for i,v in ipairs(corners) do
		local newEntry = v
		local newCost = RoomUtils.heuristic_cost_estimate(point,newEntry)
		--lume.trace(newCost)
		--lume.trace('minDist: ', minDist)
		if newCost < minDist and newCost > 0 then
			minDist = newCost
			furthestPoint = v
			--lume.trace('new min set to :', minDist, " X: ",furthesPoint.x, " Y: ", furthesPoint.y)
		end
	end
	return furthestPoint
end

function WorldGen:addExtraGoals( )
	-- body
end

function WorldGen:addExtraPaths( ... )
	-- body
end
function WorldGen:fillArea( x,y,width,height,roomName ,startX,startY,placeHolder)
	local w = width - 1
	local h = height - 1
	for i=x,(x+w) do
		for j=y,(y+h) do
			self.evalArea[i][j]["roomNo"] = self.roomsGenerated
			self.evalArea[i][j]["room"] = roomName
			-- lume.trace(roomName)
			-- util.print_table(placeHolder)
			if placeHolder then
				self.evalArea[i][j]["placeHolder"] = placeHolder
			else
				-- lume.trace("nonPlaceHolder",i,j)
				self.evalArea[i][j]["filled"] = true
				-- self.evalArea[i][j]["placeHolder"] = nil
			end
			self.evalArea[i][j]["worldX"] = startX
			self.evalArea[i][j]["worldY"] = startY
		end
	end
end

function WorldGen:setDefaultRooms()	
	self:appendStructToList("horizontal","StHoriz")
	self:appendStructToList("vertical","StVert") 
	self:appendStructToList("cornerHV","StCornerHV") 
	self:appendStructToList("cornerVH","StCornerVH") 

	self:appendStructToList("cross","StCross") 
	self:appendStructToList("ceiling","StCeil") 
	self:appendStructToList("hole","StHole") 
	self:appendStructToList("stop","StStop") 

	self:appendStructToList("exitHoriz","ExHoriz") 
	self:appendStructToList("exitTop","StStop") 
	self:appendStructToList("exitBottom","StStop") 
end

function WorldGen:loadRoom( name , dir, prevX, prevY,newX,newY)
	local roomName
	roomName = "assets/randRooms/" .. Game.roomname .. ".lua"
	-- lume.trace("================loading new Room: ", name, "with dir: ", dir)
	local prefix = string.sub(name, 1,13)
	local predef = string.sub(name,1,16)
	-- lume.trace("PREDEF: ", predef, (predef == "assets/rooms/pd-"))
	if name == "assets/rooms/Gen" then
		local roomGen = self:addNewRoom(prevX,prevY,Game.curMapTable,dir)
		local newPos = roomGen:addPreviousExit(dir, roomName, prevX, prevY,Game.WorldManager.worldX,Game.WorldManager.worldY)
		--self.evalArea[math.floor(newPos.x/32)][math.floor(newPos.y/32)]["exitDir"] = dir
		self:addOtherRoomExits(roomGen, dir)
		--lume.trace("new pos: " , newPos.x, newPos.y)
		self:processRoomChanges(Game.curMapTable, roomName, dir,prevX,prevY,newPos.x,newPos.y,roomGen.name)

		roomGen:loadRoom(newPos.x,newPos.y)
	elseif predef == "assets/rooms/pd-" then
		-- lume.trace("pd----")
		local roomGen = self:addPredefRoom(prevX,prevY,Game.curMapTable,dir,string.sub(name,17,-1))
		local newPos = roomGen:addPreviousExit(dir, roomName, prevX, prevY,Game.WorldManager.worldX,Game.WorldManager.worldY)
		--self.evalArea[math.floor(newPos.x/32)][math.floor(newPos.y/32)]["exitDir"] = dir
		self:addOtherRoomExits(roomGen, dir)
		--lume.trace("new pos: " , newPos.x, newPos.y)
		self:processRoomChanges(Game.curMapTable, roomName, dir,prevX,prevY,newPos.x,newPos.y,roomGen.name)

		roomGen:loadRoom(newPos.x,newPos.y)
	elseif prefix == "assets/rooms/" then
		Game:loadRoom(name) 
	else
		--local newTable = util.load(name)
		self:saveCurrentRoom(roomName)
		local newTable = {}
		newTable = util.persistence.load(name)
		--lume.trace(newTable)
		if not newTable then
			lume.trace("Loading previously generated room: ", name)
			error("Room does not exist!" )
		end
		self:processRoomChanges(newTable, name, RoomUtils.invertDir(dir), newX, newY, prevX,prevY, Game.roomname)

		Game.WorldManager.worldX = newTable.worldX
		Game.WorldManager.worldY = newTable.worldY
		Game:loadRoom(newTable)
	end
end

function WorldGen:saveWorld(name)
	util.persistence.store(name,Game.evalArea)
end
function WorldGen:loadWorld( name )
	newTable = util.persistence.load(name)
	self.evalArea = newTable
end

function WorldGen:processRoomChanges( mapTable, roomName , dir, prevX,prevY,newPosX,newPosY, newRoomName)
	-- lume.trace("processing Room Changes for " , roomName)
	if true then
		for i,layer in ipairs(mapTable["layers"]) do
			if layer["name"] == "Objectlayer" then
				for i2,object in ipairs(layer["objects"]) do
					if object["type"] == "ObjLevelChanger" then
						if (dir == "left" and object.x <= 32) or 
							(dir == "right" and object.x >= (mapTable["width"] * 16) - 64) or
							(dir == "up" and object.y <= 32) or 
							(dir == "down" and object.y >= (mapTable["height"] * 16) - 64) then
							lume.trace("Changed level changer to point to : ", newRoomName)
							object["properties"]["newX"] = newPosX
							object["properties"]["newY"] = newPosY
							object["properties"]["nextRoom"] = "assets/randRooms/" .. newRoomName .. ".lua"
							lume.trace("level changer changed to ", newRoomName)
						end
					end
				end
			end 
		end
		self:saveCurrentRoom(roomName)
	end
end

function WorldGen:saveCurrentRoom(roomName)
	-- lume.trace("File saved as : ", roomName)
	util.persistence.store(roomName,Game.curMapTable)
end

function WorldGen:addNewRoom(prevX,prevY,curRoom,dir,predefStruct)
	local worldX
	local worldY
	lume.trace("Adding new room with direction: " ,dir, "prevX", prevX, "prevY", prevY)
	--lume.trace("Current player coordinates: ", Game.player.x/16, Game.player.y/16)
	if dir == "left" then
		worldX = (curRoom.worldX - 1)
		worldY = curRoom.worldY + math.ceil(prevY/32) - 1
	elseif dir == "right" then
		worldX = (curRoom.worldX + math.ceil(curRoom.width/32))
		worldY = curRoom.worldY + math.ceil(prevY/32) - 1
	elseif dir == "up" then 
		worldY = (curRoom.worldY - 1)
		worldX = curRoom.worldX + math.ceil(prevX/32) - 1
	elseif dir == "down" then
		worldY = (curRoom.worldY + (curRoom.height/32))
		worldX = curRoom.worldX + math.ceil(prevX/32) - 1
	else
		error("Invalid direction for new room ")
	end
	-- self.evalArea[worldX][worldY]["spot"] = true
	-- lume.trace("Getting world area with starting Point", worldX, "Y: ", worldY)
	local area = self:getAvaliableArea(worldX,worldY)
	-- lume.trace("area: ")
	-- util.print_table(area)
	local roomWidth = Game.genRand:random(1,math.min(6,area.width - 1))
	--lume.trace("area: ", area.height)
	local roomHeight = Game.genRand:random(1,math.min(6,area.height - 1))
	--lume.trace(roomHeight)
	local startX
	local startY
	if dir == "left" or dir == "right" then
		lume.trace(worldY, roomHeight)
		local minY = math.max( 0, math.max(area.top + 1, worldY- roomHeight + 1))
		local maxY = math.min( self.worldHeight - roomHeight, math.min(area.top + area.height, worldY ))
		lume.trace("area.top: " , area.top, "area.height", area.height,"worldY: ", worldY)
		lume.trace("MinY: ", minY, "maxY", maxY)
		startY = Game.genRand:random(minY,maxY)
		lume.trace(startY)
		if dir == "left" then
			startX = worldX - roomWidth + 1
		else
			startX = worldX	
		end
	end
	if dir == "up" or dir == "down" then
		local minX = math.max( 0 ,math.max(area.left + 1, worldX - roomWidth + 1 ) )
		--lume.trace("area.left: ", area.left , "worldX: ", worldX, "roomWidth: ", roomWidth)
		local maxX = math.min( self.worldWidth - roomWidth , math.min(area.left + area.width, worldX ) )
		--lume.trace("area.left: ", area.left , "width: ", area.width, "worldX: ", worldX)
		startX = Game.genRand:random(minX,maxX)
		if dir == "up" then
			startY = worldY - roomHeight + 1
		else
			startY = worldY
		end
	end
	lume.trace("StartX: ", startX, "StartY: ", startY, "width: ",roomWidth, "height: ", roomHeight)
	local pathCounts = {}
	local exits = {}
	local maxType = ""
	local maxCount = 0
	for x=startX,(startX + roomWidth - 1) do
		for y=startY,(startY + roomHeight - 1) do
			-- lume.trace("X: " , x, "y: ", y)
			local pType = self.evalArea[x][y]["pathType"]
			--util.print_table(self.evalArea[x][y])
			-- lume.trace("X: ", x , "Y: ", y , "type: ", pType)
			if pType then
				if not pathCounts[pType] then 
					pathCounts[pType] = {}
					pathCounts[pType].count = 0
				end  
				pathCounts[pType].count = pathCounts[pType].count + 1
				pathCounts[pType].x = x
				pathCounts[pType].y = y
				if pathCounts[pType].count > maxCount then
					maxType = pType
					maxCount = pathCounts[pType].count
				end
			end
			local exit = self.evalArea[x][y]["exit"]
			if exit then
				table.insert(exits, exit)
			end
		end
	end

	local name = self:createName(exits,maxType) 
	-- lume.trace(area.left)
	-- lume.trace(area.top)
	-- lume.trace(worldX)
	-- lume.trace(worldY)

	-- lume.trace(startX)
	-- lume.trace(startY)
	-- lume.trace("roomWidth: " ,roomWidth)
	-- lume.trace("roomHeight: ", roomHeight)
	lume.trace("Area created with Left: ", startX, "Top: ", startY, "width", roomWidth, "height",roomHeight)
	if predefStruct then
		local rmgn = RoomGenPredef(roomWidth * 32,roomHeight * 32, name,startX,startY,self.embelishFunct,self.objFunct, self.enemyFunct,self.blockFunc,predefSource)
	else
		local rmgn = RoomGen(roomWidth * 32,roomHeight * 32, name,startX,startY,self.embelishFunct,self.objFunct, self.enemyFunct,self.blockFunc)
	end
	local rmgn = RoomGen(roomWidth * 32,roomHeight * 32, name,startX,startY,self.embelishFunct,self.objFunct, self.enemyFunct,self.blockFunc)
	rmgn:setType(maxType, pathCounts, pathCounts[maxType].count,self)
	if self.pregenFunc then self.pregenFunc(rmgn) end
	self:fillArea(startX,startY,roomWidth,roomHeight,name,startX,startY)
	return rmgn
end


function WorldGen:addPredefRoom(prevX,prevY,curRoom,dir,predefStruct)
	local worldX
	local worldY
	lume.trace("Adding new room with direction: " ,dir, "prevX", prevX, "prevY", prevY)
	--lume.trace("Current player coordinates: ", Game.player.x/16, Game.player.y/16)
	if dir == "left" then
		worldX = (curRoom.worldX - 1)
		worldY = curRoom.worldY + math.ceil(prevY/32) - 1
	elseif dir == "right" then
		worldX = (curRoom.worldX + math.ceil(curRoom.width/32))
		worldY = curRoom.worldY + math.ceil(prevY/32) - 1
	elseif dir == "up" then 
		worldY = (curRoom.worldY - 1)
		worldX = curRoom.worldX + math.ceil(prevX/32) - 1
	elseif dir == "down" then
		worldY = (curRoom.worldY + (curRoom.height/32))
		worldX = curRoom.worldX + math.ceil(prevX/32) - 1
	else
		error("Invalid direction for new room ")
	end

	local predefInfo =  self.evalArea[worldX][worldY]["placeHolder"]
	-- util.print_table(predefInfo)
	local roomWidth = predefInfo["width"]
	local roomHeight = predefInfo["height"]

	local startX = predefInfo["startX"]
	local startY = predefInfo["startY"]
	
	lume.trace("StartX: ", startX, "StartY: ", startY, "width: ",roomWidth, "height: ", roomHeight)
	local pathCounts = {}
	local exits = {}
	local maxType = ""
	local maxCount = 0
	for x=startX,(startX + roomWidth - 1) do
		for y=startY,(startY + roomHeight - 1) do
			-- lume.trace("X: " , x, "y: ", y)
			local pType = self.evalArea[x][y]["pathType"]
			--util.print_table(self.evalArea[x][y])
			-- lume.trace("X: ", x , "Y: ", y , "type: ", pType)
			if pType then
				if not pathCounts[pType] then 
					pathCounts[pType] = {}
					pathCounts[pType].count = 0
				end  
				pathCounts[pType].count = pathCounts[pType].count + 1
				pathCounts[pType].x = x
				pathCounts[pType].y = y
				if pathCounts[pType].count > maxCount then
					maxType = pType
					maxCount = pathCounts[pType].count
				end
			end
			local exit = self.evalArea[x][y]["exit"]
			if exit then
				table.insert(exits, exit)
			end
		end
	end

	local name = self:createName(exits,maxType) 

	lume.trace("Area created with Left: ", startX, "Top: ", startY, "width", roomWidth, "height",roomHeight)
	local rmgn = RoomGenPredef(roomWidth * 32,roomHeight * 32, name,startX,startY,self.embelishFunct,self.objFunct, self.enemyFunct,self.blockFunc,predefStruct)

	rmgn:setType(maxType, pathCounts, pathCounts[maxType].count,self)
	if self.pregenFunc then self.pregenFunc(rmgn) end
	self:fillArea(startX,startY,roomWidth,roomHeight,name,startX,startY)
	return rmgn
end

function WorldGen:createName(exit, maxType)
	if exit then
		-- lume.trace(exit)
		-- util.print_table(exit)
	end
	if maxType then
		--lume.trace(maxType)
	end
	local name = maxType or "RoomNo" .. self.roomsGenerated
	self.roomsGenerated = self.roomsGenerated + 1
	if not self.namesList[name] then
		self.namesList[name] = 0
	end
	self.namesList[name] = self.namesList[name] + 1
	name = name .. self.namesList[name]
	return name
end

function WorldGen:addOtherRoomExits(roomGen)
	-- Address Edges (top)
	local posX
	local posY
	local goalX = nil
	local goalY = nil
	local startPoint = {}
	-- lume.trace("roomGen.width:",roomGen.width, "roomGen.height:", roomGen.height)
	for x=roomGen.worldX,(roomGen.worldX + roomGen.width/32 - 1) do
		local current = self.evalArea[x][roomGen.worldY]
		if current["up"] or current["vertical"] then
			local goal = "Gen"
			local topRoom = self.evalArea[x][roomGen.worldY - 1]
			-- util.print_table(topRoom)
			if not topRoom["filled"] or (topRoom["filled"] and topRoom["room"] ~= roomGen.name  and topRoom["bExitX"]) then
				if topRoom["filled"] and topRoom["room"] ~= roomGen.name and topRoom["bExitX"] then
					goal = "assets/randRooms/" .. topRoom["room"] .. ".lua"
					goalX = topRoom["bExitX"]
					goalY = topRoom["bExitY"]
					posY = 4
					posX = ( topRoom["worldX"] - roomGen.worldX)* 32 + goalX
					lume.trace("connected to previous Room: ", goal)
					self.evalArea[x][roomGen.worldY]["tExitX"] = posX
					self.evalArea[x][roomGen.worldY]["tExitY"] = posY
					self.evalArea[x][roomGen.worldY]["exitUp"] = true
					lume.trace("Other room worldX: ", topRoom["worldX"], "myWorldX: ", roomGen.worldX, "GoalY: ", goalX)
				elseif not topRoom["filled"] then
					posX = (x - roomGen.worldX) * 32 + Game.genRand:random(1,32)
					if posX <= 8 then
						posX = posX + 8
					end
					if posX >= roomGen.width - 8 then
						posX = posX - 8
					end
					posY = 1
					self.evalArea[x][roomGen.worldY]["tExitX"] = math.ceil(posX/8) * 8 - 4
					self.evalArea[x][roomGen.worldY]["tExitY"] = 4
					self.evalArea[x][roomGen.worldY]["exitUp"] = true
					if topRoom["placeHolder"] then
						lume.trace("found placeholder room1-1-1-1-1--1-1-")
						goal = topRoom["room"]
					end
				end
				--lume.trace("x: ", x)
				lume.trace("Adding exit at : X: ", posX, "Y:", 1, "Goal: ", goal)
				--util.print_table(self.evalArea[x][roomGen.worldY - 1])
				startPoint.x = math.ceil(posX/8) * 8 - 4
				startPoint.y = 1 + 4
				roomGen:addExit(posX , 1 , goal, goalX, goalY, "up")
			end
		end
	end
	-- (bottom)
	for x=roomGen.worldX,(roomGen.worldX + roomGen.width/32 - 1) do
		-- lume.trace("Starting to Check Bottom")
		local current = self.evalArea[x][roomGen.worldY + roomGen.height/32 - 1]
		if current["down"] or current["vertical"] then
			local goal = "Gen"
			local botRoom = self.evalArea[x][roomGen.worldY + roomGen.height/32]
			-- util.print_table(botRoom)
			if not botRoom["filled"] or (botRoom["filled"] and botRoom["room"] ~= roomGen.name  and botRoom["tExitX"]) then
				if botRoom["filled"] and botRoom["room"] ~= roomGen.name  and botRoom["tExitX"] then
					goal = "assets/randRooms/" .. botRoom["room"] .. ".lua"
					goalX = botRoom["tExitX"]
					goalY = botRoom["tExitY"]
					posY = roomGen.height - 4
					posX = ( botRoom["worldX"] - roomGen.worldX) * 32 + goalX
					lume.trace("Other room worldX: ", botRoom["worldX"], "myWorldX: ", roomGen.worldX, "GoalY: ", goalX)
					self.evalArea[x][roomGen.worldY + roomGen.height/32 - 1]["bExitX"] = posX
					self.evalArea[x][roomGen.worldY + roomGen.height/32 - 1]["bExitY"] = posY
					self.evalArea[x][roomGen.worldY + roomGen.height/32 - 1]["exitDown"] = true
				elseif not botRoom["filled"] then
					posX = (x - roomGen.worldX) * 32 + Game.genRand:random(1,32)
					if posX <= 8 then
						posX = posX + 8
					end
					if posX >= roomGen.width - 8 then
						posX = posX - 8
					end
					posY = roomGen.height
					self.evalArea[x][roomGen.worldY + roomGen.height/32 - 1]["bExitX"] = math.ceil(posX/8) * 8 - 4
					self.evalArea[x][roomGen.worldY + roomGen.height/32 - 1]["bExitY"] = roomGen.height - 6
					self.evalArea[x][roomGen.worldY + roomGen.height/32 - 1]["exitDown"] = true
					lume.trace("Saving exit at X: ", posX, "Y: ", posY)
					if botRoom["placeHolder"] then
						lume.trace("found placeholder room1-1-1-1-1--1-1-")
						goal = botRoom["room"]
					end
				end
				--lume.trace("Hello the bottom is at X: ", x, "Y: ", roomGen.worldY + 1)
				--util.print_table(self.evalArea[x][roomGen.worldY + 1])

				local roomX = x - roomGen.worldX + 1
				lume.trace("Adding exit at : ", posX, roomGen.height, "Goal: ", goal)
				startPoint.x = math.ceil(posX/8) * 8 - 4
				startPoint.y = math.ceil(roomGen.height/8)*8 - 6

				roomGen:addExit(posX , roomGen.height, goal, goalX, goalY, "down")
			end
		end
	end
	-- (left)
	for y=roomGen.worldY,(roomGen.worldY + roomGen.height/32 - 1) do
		local current = self.evalArea[roomGen.worldX][y]
		if current["left"] or current["horizontal"] then
			local goal = "Gen"
			local leftRoom = self.evalArea[roomGen.worldX - 1][y]
			-- util.print_table(leftRoom)
			if not leftRoom["filled"] or (leftRoom["filled"] and leftRoom["room"] ~= roomGen.name and leftRoom["rExitX"]) then
				if leftRoom["filled"] and leftRoom["room"] ~= roomGen.name and leftRoom["rExitX"] then
					goal = "assets/randRooms/" .. leftRoom["room"] .. ".lua"
					goalX = leftRoom["rExitX"]
					goalY = leftRoom["rExitY"]
					posX = 4
					posY =( leftRoom["worldY"] - roomGen.worldY)* 32 + goalY
					self.evalArea[roomGen.worldX][y]["lExitX"] = posX
					self.evalArea[roomGen.worldX][y]["lExitY"] = posY
					self.evalArea[roomGen.worldX][y]["exitLeft"] = true
					lume.trace("Other room worldY: ", leftRoom["worldY"], "myWorldY: ", roomGen.worldY, "GoalY: ", goalY)
				elseif not leftRoom["filled"] then
					posX = 1
					posY = (y - roomGen.worldY) * 32 + Game.genRand:random(1,32)
					if posY <= 8 then
						posY = posY + 8
					end
					if posY >= roomGen.height - 8 then
						posY = posY - 8
					end
					self.evalArea[roomGen.worldX][y]["lExitX"] = 1 + 4
					self.evalArea[roomGen.worldX][y]["lExitY"] = math.ceil(posY/8) * 8 - 4
					self.evalArea[roomGen.worldX][y]["exitLeft"] = true
					-- lume.trace("Saving exit at X: ", posX, "Y: ", posY)
					if leftRoom["placeHolder"] then
						lume.trace("found placeholder room1-1-1-1-1--1-1-")
						goal = leftRoom["room"]
					end
				end
				lume.trace("Adding exit at : ", 1, posY, "Goal: ", goal)
				--lume.trace("Hello the left is at: ", roomGen.worldX - 1, "Y: ", y)
				--util.print_table(leftRoom)
				startPoint.x = 1 + 4
				startPoint.y = math.ceil(posY/8) * 8 - 4
				roomGen:addExit(1 , posY , goal, goalX, goalY, "left")
			end
		end
	end
	-- (right)
	for y=roomGen.worldY,(roomGen.worldY + roomGen.height/32 - 1) do
		local current = self.evalArea[roomGen.worldX + roomGen.width/32 - 1][y]
		if current["right"] or current["horizontal"] then
			local goal = "Gen"
			local rightRoom = self.evalArea[roomGen.worldX + roomGen.width/32][y]
			-- util.print_table(rightRoom)
			if not rightRoom["filled"] or (rightRoom["filled"] and rightRoom["room"] ~= roomGen.name and rightRoom["lExitX"]) then
				if rightRoom["filled"] and rightRoom["room"] ~= roomGen.name and rightRoom["lExitX"] then
					goal = "assets/randRooms/" .. rightRoom["room"] .. ".lua"
					goalX = rightRoom["lExitX"]
					goalY = rightRoom["lExitY"]
					posX = roomGen.width - 4
					posY =( rightRoom["worldY"] - roomGen.worldY)* 32 + goalY
					self.evalArea[roomGen.worldX + roomGen.width/32 - 1][y]["rExitX"] = posX
					self.evalArea[roomGen.worldX + roomGen.width/32 - 1][y]["rExitY"] = posY
					self.evalArea[roomGen.worldX + roomGen.width/32 - 1][y]["exitRight"] = true
					lume.trace("Other room worldY: ", rightRoom["worldY"], "myWorldY: ", roomGen.worldY, "GoalY: ", goalY)
				elseif not rightRoom["filled"] then
					posX = roomGen.width
					posY = (y - roomGen.worldY) * 32 + Game.genRand:random(1,32)
					if posY <= 8 then
						posY = posY + 8
					end
					if posY >= roomGen.height - 8 then
						posY = posY - 8
					end
					self.evalArea[roomGen.worldX + roomGen.width/32 - 1][y]["rExitX"] = roomGen.width - 4
					self.evalArea[roomGen.worldX + roomGen.width/32 - 1][y]["rExitY"] = math.ceil(posY/8) * 8 - 4
					self.evalArea[roomGen.worldX + roomGen.width/32 - 1][y]["exitRight"] = true
					lume.trace("Saving exit at X: ", posX, "Y: ", posY)
					if rightRoom["placeHolder"] then
						lume.trace("found placeholder room1-1-1-1-1--1-1-")
						goal = rightRoom["room"]
					end
				end
				lume.trace("y: ", y)
				lume.trace("Adding exit at : ", roomGen.width, posY, "Goal: ", goal)
				startPoint.x = math.ceil(roomGen.width/8)*8 - 4
				startPoint.y = math.ceil(posY/8) * 8 - 4
				roomGen:addExit(roomGen.width , posY, goal, goalX, goalY, "right")
			end
		end
	end
	return startPoint
end

function WorldGen:generateDefaultStructList()
	local list = {}
	local StHoriz = require("roomgen.StHoriz")
	local newSt = StHoriz(self.room,self.evalArea)
	table.insert(list,"roomgen.StHoriz")
	-- local StStairs = require("roomgen.StStairs")
	-- local newSt = StStairs()
	-- table.insert(list,newSt)
	return list
end

function WorldGen:appendRoomToList(structType, structName)
	local list = self.structList[structType]
	if not list then
		self.structList[structType] = {}
		list = self.structList[structType]
	end
	local newType = "roomgen." .. structName
	-- lume.trace("added struct of type: ", newType)
	table.insert(list,newType)
end

function WorldGen:addRandRoom( structType, x, y,width, height,centX,centY ,reverse ,params)
	local currList = self.structList[structType]
	local newStruct = false
	while (true) do 
		newStruct = self:randomStruct(currList)
		if newStruct:canFit(x, y,width, height,centX,centY ,reverse) then
			self:addStruct(newStruct, x * 8 - 8, y * 8 - 8,width * 8, height * 8,centX * 8 - 8,centY * 8 - 8,reverse ,params)
			--lume.trace('Struct Added of type: ', structType)
			break
		end
		--lume.trace(newStruct:canFit(x, y,width, height,centX,centY ,reverse))
		--lume.trace(currList)
		--lume.trace(newStruct)
		util.deleteFromTable(currList,newStruct)
		hio = 9
	end
end
function WorldGen:randomStruct(structures)
	local probs = {}
	local totalWeight = 0
	for i,v in ipairs(structures) do
		local structureEntry = {}
		structureEntry.weight = 10
		totalWeight = totalWeight + 10
		structureEntry.structPath = v
		table.insert(probs,structureEntry)
	end
	local randVal = Game.genRand:random()
	local totalRand = 0

	for i,v in pairs(probs) do
		totalRand = totalRand + v.weight
		if totalRand > randVal then
			local newClass = require(v.structPath)
			local newStruct = newClass(self.room,self.evalArea)
			return newStruct
		end
	end
end
function WorldGen:tileBlocked( x,y, centX,centY,dir)
	--lume.trace("x: ", x , "y: ", y)
	if self.evalArea[x][y]["filled"] or self.evalArea[x][y]["placeHolder"] then
		-- lume.trace("Tile BLocked")
		-- lume.trace(dir)
		-- lume.trace(x)
		-- lume.trace(y)
		return true
	end
	return false
end

function WorldGen:getAvaliableArea(x,y,table)
	--lume.trace("calculating avaliable area")
	--util.print_table(self.evalArea)
	--util.print_table(self.evalArea[x][y]) 
	if self:tileBlocked(x,y,x,y,'up') then
		lume.trace("initial blocked")
		lume.trace("initial x: ", x, "Y: ", y)
		util.print_table(self.evalArea[x][y])
		util.print_table(self.evalArea[x][y - 1])
		error("Not enough area to make new room")
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
	area.width = right - left
	area.height = bottom - top
	area.left = left
	area.top = top
	area.endX = left + area.width
	area.endY = top + area.height
	area.centX = x
	area.centY = y
	--lume.trace("finished calculating area")
	--util.print_table(area)
	return area
end

return WorldGen