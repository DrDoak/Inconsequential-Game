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
	struct:interSpaceStruct("SSHangingLight","fground","ceiling",2,0.2,nil)
	struct:interSpaceStruct("SSGroundLight","fground","ground",2,0.4,nil)
	if sType == "StHoriz" then
		if Game.genRand:random(1,2) == 1 then
			roomgen:setSubTheme(roomgen.baseTheme)
			struct:interSpaceStruct("SSBottom","bkg3","ground",nil,1.0,1)
			struct:interSpaceTile("wall_top","bkg2","ceiling",nil,1.0,nil)

			struct:interSpaceTile("wall_edge","bkg2","leftSide",nil,1.0,nil)
			struct:interSpaceTile("wall_edge","bkg2","rightSide",nil,1.0,nil, true)

			struct:interSpaceStruct( "SSBand", "bkg3","leftSide" , 2, 1.0, nil)
			struct:fillBackground("wall")
		else
			struct:interSpaceStruct("SSLowFence", "fground","ground",4,0.3,2)			
			struct:interSpaceStruct("SSFence", "fground","ground",4,0.2,2)
		end
		-- struct:interSpaceStruct("SSHangingLight","fground","ceiling",2,0.2,nil)
	elseif sType == "VtJumpsSolid" or sType == "VtStairway" or sType == "VtDrops" or sType == "VtJumpsSmall" then
		roomgen:setSubTheme("dark_building")
		if Game.genRand:random(1,2) == 1 then
			struct:interSpaceTile("baseBoard","bkg2","ground",nil,1.0,nil)
		else
			struct:interSpaceTile("curve_edge","bkg2","leftSide",nil,1.0,nil)
			struct:interSpaceTile("curve_edge","bkg2","rightSide",nil,1.0,nil, true)
		end

		struct:interSpaceStruct("SSGroundLight","fground","ground",2,0.1,nil)

		struct:interSpaceStruct("SSLightSide",{side="right"},"rightSide",4,1.0,nil)
		struct:interSpaceStruct("SSLightSide",{side="left"}, "leftSide",4,1.0,nil)
		struct:fillBackground("wall")
	elseif sType == "StVert" then
		roomgen:setSubTheme(roomgen.otherTheme)
		struct:interSpaceStruct("SSLightSide",{side="right"},"rightSide",4,1.0,nil)
		struct:interSpaceStruct("SSLightSide",{side="left"}, "leftSide",4,1.0,nil)
		struct:fillBackground("wall")
	else
		--struct:interSpaceTile("wall_top","bkg2","ceiling",nil,1.0,nil)
		--struct:interSpaceStruct("SSBottom","bkg3","ground",nil,1.0,1)
		
		struct:interSpaceStruct("SSGroundLight","fground","ground",2,0.2,nil)
		-- struct:interSpaceStruct("SSCeilingLight","fground","ceiling",2,0.2,nil)
		struct:interSpaceStruct("SSHangingLight","fground","ceiling",2,0.2,nil)

		-- struct:interSpaceStruct("SSLightSide",{side="right"},"rightSide",4,1.0,nil)
		-- struct:interSpaceStruct("SSLightSide",{side="left"}, "leftSide",4,1.0,nil)

		struct:interSpaceTile("baseBoard","bkg2","ground",nil,1.0,nil)
		struct:fillBackground("wall")
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

local FadeCombinations = require ("roomgen.enLists.FadeCombinations")

local function enFunct(roomgen, struct)
	--if struct.structType == "StHoriz" and math.random(1,2) == 1 then
		roomgen:randomEnemy(FadeCombinations, struct)
--end
end

local function getRandTheme()
	local themeString 
	local rand = Game.genRand:random(1,4)
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
	roomgen.room:addRoomProperty("use_lights", "true" )
	roomgen.baseTheme = getRandTheme()
	roomgen.otherTheme = getRandTheme()
	roomgen:setBackground("BkgHetairoi")
end

WRHetairoi:setPreGenFunct(pregenFunct)
WRHetairoi:setGenerationFunction(pathGenFunct)
WRHetairoi:setEmbelishmentFunction(embelishFunct)
WRHetairoi:setObjGenerationFunction(objFunct)
WRHetairoi:setEnemyFunction(enFunct)

return WRHetairoi