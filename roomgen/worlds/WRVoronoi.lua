local WorldGen = require "roomgen.WorldGen"
local RoomUtils = require "roomgen.RoomUtils"
local VoronoiSolve = require "roomgen.voronoi.VoronoiSolve"
local Node = require "roomgen.voronoi.Node"
local Edge = require "roomgen.voronoi.Edge"
local Graph = require "roomgen.voronoi.Graph"
local WRVoronoi =  WorldGen(24,32)

local function pathGenFunct( gen )
	lume.trace("Starting Path Gen Funct")
	local seed = os.time()
	math.randomseed(seed)
	lume.trace(seed)
	local startPoint = 	gen:addRandomGoalInRange(12,28, 6,1,"startPoint","Hetairoi_StartingRoom")				-- Initial Point
	local centers = {}
	local nodes = {}
	local numCenters = 6
	local width = 24
	local height = 32
	local interactions = {
		{difficulty = 15,intType = "boss"},
		{difficulty = 5,intType = "enemy"},
		{difficulty = 10,intType = "trap"},
		{difficulty = 50,intType = "miniboss"},
		{difficulty = 20,intType = "mob"},
		{difficulty = 20,intType = "platforming"},
		{difficulty = 25,intType = "puzzle"}
	}
	-- Place Centers
	local unconnected = {}
	local newNode = Node(1, startPoint.x,startPoint.y,0,true)
	table.insert(nodes,newNode)
	table.insert(centers,newNode)
	table.insert(unconnected,newNode)
	for i=1,numCenters do
		local newNode = Node(i+1,math.random(2,width-2),math.random(2,height-2),interactions[1].difficulty,true)
		newNode.intType = interactions[1].intType
		local name = "center Number " .. i
		gen:addGoal(newNode.x,newNode.y,name,"Hetairoi_SavePoint",newNode.id)
		table.insert(nodes,newNode)
		table.insert(centers,newNode)
		table.insert(unconnected,newNode)
	end

	local connected = {}
	table.insert(connected,unconnected[1])
	table.remove(unconnected,1)
	while (#unconnected > 0 ) do 
		local closestNode = RoomUtils.closest(unconnected[1],connected)
		--gen:generatePath(unconnected[1].pos,closestNode.pos,"edge")
		local newEdge = Edge(unconnected[1],closestNode)
		table.insert(connected,unconnected[1])
		table.remove(unconnected,1)
	end

	-- Place other nodes
	for i=1,math.random(15,25) do
		local mInteraction = interactions[math.random(2,6)]
		local newNode = Node(i + numCenters+1,math.random(2,width-2),math.random(2,height-2),mInteraction.difficulty)
		newNode.intType = mInteraction.intType
		table.insert(nodes,newNode)
		local name = "Extra Goal Number " .. i
		gen:addInteraction(newNode.x,newNode.y,{intType=mInteraction.intType,difficulty=mInteraction.difficulty})
		local connections = {}
		for i,v in ipairs(connected) do
			table.insert(connections,v)
		end
		for i=1,math.random(1,3) do --math.random(1,3) do
			local closestNode = RoomUtils.closest(newNode,centers)
			local newEdge = Edge(newNode,closestNode)
			--gen:generatePath(newNode.pos,closestNode.pos,"edge")
			util.deleteFromTable(connections,closestNode)	
		end
		table.insert(connected,newNode)
	end

	local mGraph = Graph(nodes)
	local modGraph = VoronoiSolve.weighted_voronoi_diagram(mGraph,centers)

	for i,node in ipairs(modGraph.nodeList) do
		-- util.print_table(node.edges)
		if not node.isCenter then
			gen:generatePath(node.pos,node.currentClosest.pos,node.currentClosest.id)
		else
			for otherNode,edge in pairs(node.edges) do
			 	gen:generatePath(node.pos,otherNode.currentClosest.pos,node.currentClosest.id)
			end
		end
	end
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
	--	roomgen:randomEnemy(FadeCombinations, struct)
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

WRVoronoi:setPreGenFunct(pregenFunct)
WRVoronoi:setGenerationFunction(pathGenFunct)
WRVoronoi:setEmbelishmentFunction(embelishFunct)
WRVoronoi:setObjGenerationFunction(objFunct)
WRVoronoi:setEnemyFunction(enFunct)

return WRVoronoi