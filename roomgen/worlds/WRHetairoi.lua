local WorldGen = require "roomgen.WorldGen"
local WRHetairoi =  WorldGen(24,48)

local function pathGenFunct( gen )
	local startPoint = 	gen:addRandomGoalInRange(12,44, 6,1,"startPoint","Hetairoi_StartingRoom")				-- Initial Point
	local backwardPoint, shopPoint, sewarPoint, mallPoint, hetairoiPoint, skyPoint
	if math.random(1,2) == 1 then -- Initial Point
		backwardPoint = gen:addRandomGoalInRange(20,45, 4,1,"hidden pit","Hetairoi_SavePoint")	
		shopPoint = gen:addRandomGoalInRange(5,40, 4,2,"Old Central Square","Hetairoi_SavePoint")
	else
		backwardPoint = gen:addRandomGoalInRange(5,45, 4,1,"hidden pit","Hetairoi_SavePoint")
		shopPoint = gen:addRandomGoalInRange(20,40, 4,2,"Old Central Square","Hetairoi_SavePoint")
	end

	if math.random(1,2) == 1 then
		sewarPoint = 	gen:addRandomGoalInRange(5,30, 4,4,"Sewar Entrace","Hetairoi_SavePoint")
		mallPoint = 	gen:addRandomGoalInRange(20,30, 4,4,"Abandoned Shopping District","Hetairoi_SavePoint","Hetairoi_SavePoint")
		skyPoint = 		gen:addRandomGoalInRange(5,20, 4,4,"Sky Point","Hetairoi_SavePoint")
		hetairoiPoint = gen:addRandomGoalInRange(20,20, 4,4,"Hetairoi Base","Hetairoi_SavePoint")
	else
		sewarPoint = 	gen:addRandomGoalInRange(20,30, 4,4,"Sewar Entrace","Hetairoi_SavePoint")
		mallPoint = 	gen:addRandomGoalInRange(5,30, 4,4,"Abandoned Shopping District","Hetairoi_SavePoint")
		skyPoint = 		gen:addRandomGoalInRange(20,20, 4,4,"Sky Point","Hetairoi_SavePoint")
		hetairoiPoint = gen:addRandomGoalInRange(5,20, 4,4,"Hetairoi Base","Hetairoi_SavePoint")
	end

	local bossPoint = gen:addRandomGoalInRange(12,10,6,2,"Old Prison","Hetairoi_SavePoint")
	local endPoint = gen:addRandomGoalInRange(12,2,6,1, "Path to Moratorium","Hetairoi_SavePoint")

	gen:generatePath(startPoint,backwardPoint, "Lower Alleys")
	gen:generatePath(startPoint,shopPoint, "Lower Alleys")
	gen:generatePath(shopPoint,sewarPoint, "Abandoned Street")
	gen:generatePath(shopPoint,mallPoint, "Abandoned Street")
	-- gen:generatePath(sewarPoint,hetairoiPoint, "Aquaducts")
	-- gen:generatePath(sewarPoint,skyPoint, "Aquaducts")
	-- gen:generatePath(hetairoiPoint,skyPoint, "Skywards")
	-- gen:generatePath(hetairoiPoint,bossPoint, "Hetairoi Base")
	-- gen:generatePath(skyPoint,bossPoint, "Skywards")
	-- gen:generatePath(bossPoint,endPoint,"Old BoneYards")
	local startPos = gen:addPreDefinedRoom( 64,64,"Starting Point", startPoint.x,startPoint.y , "Hetairoi_StartingRoom")
	gen.initRoom = startPos[1]
	gen.startPos = startPos[2]
	-- lume.trace("finished creating wolrd with initial position")
	-- util.print_table(gen.startPos)
end

local function embelishFunct(roomgen, struct)
	roomgen:setSubTheme(roomgen.baseTheme)
	local sType = struct.structType
	if sType == "StVert" then
		struct:fillBackground("wall")
	end
	if sType ~= "StVert" and sType ~= "StPredef" and sType ~= "StCornerHV" and sType ~= "StCeil" and sType ~= "ExBottom" then
		struct:addBackWall("baseBoard")
	end
end

local function objFunct(roomgen, struct)
	-- lume.trace("embelishFunct")
	-- lume.trace(struct.structType)
	local sType = struct.structType
	if Game.genRand:random(1,100) < 3 then
		-- struct:interSpaceStruct("SSChest",{leak=true},"ceiling",2,0.1,nil)
		struct:interSpaceStruct("SSChest",{leak=true},"ground",2,0.1,nil)
		-- if math.random()
	end

	if Game.genRand:random(1,100) == 1 then
		-- struct:interSpaceStruct("SSChest",{leak=true},"ceiling",2,0.1,nil)
		struct:interSpaceStruct("SSVending",{leak=true},"ground",2,0.1,nil)
		-- if math.random()
	end
end

local normalEnemies = require ("roomgen.enLists.normalEnemies")

local function enFunct(roomgen, struct)
	if struct.structType == "StHoriz" or struct.structType == "StVert" and math.random(1,2) == 1 then
		roomgen:randomEnemy(normalEnemies, struct)
	end
end

local function getRandTheme()
	local themeString 
	local rand = 3 --Game.genRand:random(1,4)
	if rand == 1 then
		themeString = "red_building"
	elseif rand == 2 then
		themeString = "yellow_building"
	elseif rand == 3 then
		themeString = "orange_building"
	elseif rand == 4 then
		themeString = "dark_building"
	end
	return themeString
end

local function pregenFunct( roomgen )
	-- roomgen.room:addRoomProperty("use_lights", "true" )
	roomgen.baseTheme = getRandTheme()
	roomgen.otherTheme = getRandTheme()
	-- roomgen:setBackground("BkgHetairoi")
end

WRHetairoi:setPreGenFunct(pregenFunct)
WRHetairoi:setGenerationFunction(pathGenFunct)
WRHetairoi:setEmbelishmentFunction(embelishFunct)
WRHetairoi:setObjGenerationFunction(objFunct)
WRHetairoi:setEnemyFunction(enFunct)

return WRHetairoi