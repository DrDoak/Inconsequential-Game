local RoomUtils = {}
local util = require "util"

function RoomUtils.toAbsCoords( oldTable )
	local newTable = {}
	for i,v in ipairs(oldTable) do
		local newEntry = {}
		newEntry.x = v.x * 16
		newEntry.y = v.y * 16
		table.insert(newTable,newEntry)
	end
	return newTable
end

function RoomUtils.toTileCoords( oldTable )
	local newTable = {}
	for i,v in ipairs(oldTable) do
		local newEntry = {}
		newEntry.x = v.x / 16
		newEntry.y = v.y / 16
		table.insert(newTable,newEntry)
	end
	return newTable
end

function RoomUtils.offset( oldTable ,x,y)
	local newTable = {}
	for i,v in ipairs(oldTable) do
		local newEntry = {}
		newEntry.x = v.x + x
		newEntry.y = v.y + y
		table.insert(newTable,newEntry)
	end
	return newTable
end

function RoomUtils.furthest( point ,searchTable)
	local maxDist = 0
	local furthestPoint = {}
	for i,v in ipairs(searchTable) do
		local newCost = RoomUtils.heuristic_cost_estimate(point,v)
		--lume.trace("offset", (newCost > maxDist), "equal ", (point.x ~= v.x))
		if newCost > maxDist and not (point.x == v.x and point.y == v.y) then
			maxDist = newCost
			furthestPoint = v
		end
	end
	return furthestPoint
end

function RoomUtils.closest( point, searchTable )
	local minDist = 99999999
	local closestPoint = {}
	for i,v in ipairs(searchTable) do
		local newCost = RoomUtils.heuristic_cost_estimate(point,v)
		if newCost < minDist and not (point.x == v.x and point.y == v.y) then
			minDist = newCost
			closestPoint = v
		end
	end
	return closestPoint
end

function RoomUtils.initialize2dArray( width ,height	,value)
	local newTable = {}
	local currentWidth = 1
	local currentHeight = 1
	while (currentWidth <= width) do
		newTable[currentWidth] = {}
		while (currentHeight <= height) do
			newTable[currentWidth][currentHeight] = value
			currentHeight = currentHeight + 1
		end
		currentHeight = 1
		currentWidth = currentWidth + 1
	end
	return newTable
end

function RoomUtils.initialize2dTableArray( width ,height)
	local newTable = {}
	local currentWidth = 1
	local currentHeight = 1
	while (currentWidth <= width) do
		newTable[currentWidth] = {}
		while (currentHeight <= height) do
			local tableVal = {}
			newTable[currentWidth][currentHeight] = tableVal
			currentHeight = currentHeight + 1
		end
		currentHeight = 1
		currentWidth = currentWidth + 1
	end
	return newTable
end

function RoomUtils.randomPath(start, goal,map,width,height, nl, blockFunct,pathType)
	--lume.trace("Starting Random Path generation")
	--lume.trace("Eval Area:")
	--util.print_table(map)

	local bestMap 
	local numberBlocks = 0
	local maxBlocks = (width * height ) * 0.7
	local found = false
	local noList = nl or {{x=-1,y=-1}}
	--util.print_table(map)

	local function random_Blocks(start, goal,width, height, blockList) 
		local newBlock = {}
		newBlock.x = Game.genRand:random(1,width)
		newBlock.y = Game.genRand:random(1,height)
		return newBlock
	end

	local blockFunct = blockFunct or random_Blocks
	if false then
		return RoomUtils.Astar(start, goal,map,width,height,noList,pathType)
	else 
		while true do
			local numberTries = 1
			local newBlock = {}	
			while true do
				--lume.trace("attempt ", numberTries)
				newBlock = {}
				while true do
					newBlock = blockFunct(start, goal,width, height, noList)
					if not RoomUtils.hasCoordinate(noList, newBlock) then
						break
					end
				end
				--lume.trace('New block added at')
				--util.print_table(newBlock)
				local newList = util.deepcopy(noList)
				table.insert(newList,newBlock)
				--lume.trace("trying A star search")
				local result = RoomUtils.Astar(start, goal,map,width,height,newList,pathType)
				if result then
					found = true
					bestMap = result --{result,length}
					break
				elseif numberTries > 5 then
					--lume.trace("quota met breaking out")
					break
				end
				numberTries = numberTries + 1
			end
			if found then
				-- lume.trace("successFul generation, adding new block")
				found = false
				numberBlocks = numberBlocks + 1
				table.insert(noList,newBlock)
				break
				-- if numberBlocks > maxBlocks then
				-- 	--lume.trace("Exceeded number of block quota, breaking out")
				-- 	break
				-- end
			else
				--lume.trace("returning best path thus far")
				break
			end
		end
		--lume.trace("Created path with number of blocks: " , numberBlocks)
		if numberBlocks == 0 then
			lume.trace("====path error ===")
			util.print_table(start)
			util.print_table(goal)
			lume.trace("width: ", width, "height: ", height)
			error("Path could not be generated in Room")
		end
		return bestMap
	end
end

function RoomUtils.Astar(start, goal,map,width,height,noList,pathType)
	-- lume.trace("initializing A star search")
	local newMap = util.deepcopy(map)

    -- The set of nodes already evaluated.
    local closedSet = {}
    --The set of currently discovered nodes still to be evaluated.
    --Initially, only the start node is known.
    local openSet = {}
    table.insert(openSet,start)
    --For each node, which node it can most efficiently be reached from.
    --If a node can be reached from many nodes, cameFrom will eventually contain the
    --most efficient previous step.
    -- local cameFrom = RoomUtils.initialize2dArray( width ,height,99999)
    local cameFrom = {}

    -- For each node, the cost of getting from the start node to that node.
    local gScore = RoomUtils.initialize2dArray( width ,height,99999)
    -- The cost of going from start to start is zero.
    gScore[start.x][start.y] = 0 
    -- For each node, the total cost of getting from the start node to the goal
    -- by passing by that node. That value is partly known, partly heuristic.
    local fScore = RoomUtils.initialize2dArray( width ,height,99999)
    -- For the first node, that value is completely heuristic.
    fScore[start] = RoomUtils.heuristic_cost_estimate(start, goal)
    cameFrom[start.x] = {}
    cameFrom[start.x][start.y] = 0
    cameFrom["end"] = true
    local newIteration = 0
    while (table.getn(openSet) > 0) do
    	local minI = 0
    	local minVal = 999999
    	for i,v in ipairs(openSet) do
    		local newScore = fScore[v.x][v.y]
    		if newScore < minVal then
    			minI = i
    			minVal = newScore
    		end
    	end
    	local current = openSet[minI]
    	-- lume.trace("current: ")
    	-- util.print_table(current)
    	--lume.trace("goal: ")
    	--util.print_table(goal)
        if current.x == goal.x and current.y == goal.y then
            return RoomUtils.reconstruct_path(cameFrom, current, newMap,pathType,gScore[current.x][current.y] + 1)
        end

        table.remove(openSet,minI)
        table.insert(closedSet,current)
		-- lume.trace(noList)
        local neighbors = RoomUtils.getNeighbors(current,newMap,width,height,noList)
        for i,v in ipairs(neighbors) do
            if not RoomUtils.hasCoordinate(closedSet,v) then
	            --The distfance from start to a neighbor
	            local tentative_gScore = gScore[current.x][current.y] + RoomUtils.dist_between(current, v)
	            if not RoomUtils.hasCoordinate(openSet,v)	then -- Discover a new node
	                table.insert(openSet, v)
	                -- This path is the best until now. Record it!
	                if not cameFrom[v.x] then
	                	cameFrom[v.x] = {}
	                end
	                if not cameFrom[v.x][v.y] then
	                	cameFrom[v.x][v.y] = {}
	                end
	                local newValue = {}
			        cameFrom[v.x][v.y] = util.deepcopy(current)
			        gScore[v.x][v.y] = tentative_gScore
			        fScore[v.x][v.y] = gScore[v.x][v.y] + RoomUtils.heuristic_cost_estimate(v, goal) 
	            elseif tentative_gScore >= gScore[v.x][v.y] then
	            	-- lume.trace("not a better path")
	                -- continue		-- This is not a better path.
	            end
	        end           
        end
        newIteration = newIteration + 1
        if newIteration > 500 then
        	--lume.trace('A star failed due to iternation')
        	break
        end
    end
    -- lume.trace("A star search failed")
    --lume.trace(newIteration)
    return false
end

function RoomUtils.heuristic_cost_estimate( start,goal )
	return math.abs(goal.x - start.x) + math.abs(goal.y - start.y)
end

function RoomUtils.combineTables(output, appendum)
	for i,v in ipairs(appendum) do
		for i2,v2 in ipairs(v) do
			for k,v3 in pairs(v2) do
				output[i][i2][k] = v3
			end
		end
	end
end

function RoomUtils.reconstruct_path( cameFrom,current, map ,pathType,totalLength)
	local newCurrent = current
	local previousDir = "none"
	local previousPos = {}
	local curPos = 0
	previousPos.x = current.x
	previousPos.y = current.y
	-- fhiw = 9 
	map[current.x][current.y]["exit"] = true
	while cameFrom[current.x][current.y] do
		curPos = curPos + 1
		newCurrent = cameFrom[current.x][current.y]
		map[current.x][current.y]["inPath"] = true
		if curPos >= totalLength/2 then
			map[current.x][current.y]["pathType"] = pathType or 1
		else
			map[current.x][current.y]["secondaryType"] = pathType or 1
		end
		if newCurrent == 0 then
			map[current.x][current.y][previousDir] = true
			map[current.x][current.y]["exit"] = true
			break
		end
		--lume.trace("X: ",current.x,"Y: ", current.y)
		--lume.trace("NewX: ",newCurrent.x,"NewY: ", newCurrent.y)
		if map[current.x][current.y]["horizontal"] then
			map[current.x][current.y]["left"] = true
			map[current.x][current.y]["right"] = true
			if current.x == newCurrent.x then
				if newCurrent.y > current.y then
					map[current.x][current.y]["corner"] = true
					map[current.x][current.y]["down"] = true
				elseif newCurrent.y < current.y then 
					map[current.x][current.y]["corner"] = true
					map[current.x][current.y]["up"] = true
				end
			end
		elseif map[current.x][current.y]["vertical"] then
			map[current.x][current.y]["up"] = true
			map[current.x][current.y]["down"] = true
			if current.y == newCurrent.y then
				if newCurrent.x > current.x then
					map[current.x][current.y]["corner"] = true
					map[current.x][current.y]["right"] = true
				elseif newCurrent.x < current.x then
					map[current.x][current.y]["corner"] = true
					map[current.x][current.y]["left"] = true
				end
			end
		end
		if current.x == newCurrent.x then
			if previousDir == "vertical" then 
				map[current.x][current.y]["vertical"] = true
				map[current.x][current.y]["up"] = true
				map[current.x][current.y]["down"] = true
			else
				-- if map[current.x][current.y] == 0 then
				-- 	map[current.x][current.y] = {}
				-- end

				if previousPos.x > current.x then
					if newCurrent.y > current.y then
						map[current.x][current.y]["corner"] = true
						map[current.x][current.y]["down"] = true
						map[current.x][current.y]["right"] = true
					else
						map[current.x][current.y]["corner"] = true
						map[current.x][current.y]["up"] = true
						map[current.x][current.y]["right"] = true
					end
				else
					if newCurrent.y > current.y then
						map[current.x][current.y]["corner"] = true
						map[current.x][current.y]["down"] = true
						map[current.x][current.y]["left"] = true
					else
						map[current.x][current.y]["corner"] = true
						map[current.x][current.y]["up"] = true
						map[current.x][current.y]["left"] = true
					end
				end
			end
			previousDir = "vertical"
			
		elseif current.y == newCurrent.y then
			if previousDir == "horizontal" then --previousPos.x and map[previousPos.x][previousPos.y]["horizontal"] then--
				map[current.x][current.y]["horizontal"] = true
				map[current.x][current.y]["left"] = true
				map[current.x][current.y]["right"] = true
			else
				if previousPos.y > current.y then
					if newCurrent.x > current.x then
						map[current.x][current.y]["corner"] = true
						map[current.x][current.y]["down"] = true
						map[current.x][current.y]["right"] = true
					else
						map[current.x][current.y]["corner"] = true
						map[current.x][current.y]["down"] = true
						map[current.x][current.y]["left"] = true
					end
				else
					if newCurrent.x > current.x then
						map[current.x][current.y]["corner"] = true
						map[current.x][current.y]["up"] = true
						map[current.x][current.y]["right"] = true
					else
						map[current.x][current.y]["corner"] = true
						map[current.x][current.y]["up"] = true
						map[current.x][current.y]["left"] = true
					end
				end
			end
			previousDir = "horizontal"
		else
			lume.trace("invalid path constructed")
		end
		previousPos = util.deepcopy(current)
		current = util.deepcopy(newCurrent)
	end
	return {map,totalLength}
end

function RoomUtils.getNeighbors( current,map,width,height,noList)
	local neighbors = {}
	-- lume.trace(noList)
	-- lume.trace("x: " ,current.x , "y: " , current.y)
	-- lume.trace("width: " ,width , "height: " , height)
	if current.x > 1 then
		local newPoint = {}
		newPoint.x = current.x - 1
		newPoint.y = current.y
		if not RoomUtils.hasCoordinate(noList,newPoint) then
			table.insert(neighbors,newPoint) 
		end
	end
	if current.y > 1 then
		local newPoint2 = {}
		newPoint2.x = current.x
		newPoint2.y = current.y - 1
		if not RoomUtils.hasCoordinate(noList,newPoint2) then
			table.insert(neighbors,newPoint2) 
		end
	end
	if current.x < width then
		local newPoint3 = {}
		newPoint3.x = current.x + 1
		newPoint3.y = current.y
		if not RoomUtils.hasCoordinate(noList,newPoint3) then
			table.insert(neighbors,newPoint3) 
		end
	end
	if current.y < height then
		local newPoint4 = {}
		newPoint4.x = current.x
		newPoint4.y = current.y + 1
		if not RoomUtils.hasCoordinate(noList,newPoint4) then
			table.insert(neighbors,newPoint4) 
		end
	end
	-- if table.getn(neighbors) == 0 then
	-- 	lume.trace("current:")
	-- 	util.print_table(current)
	-- 	lume.trace("neighbors:")
	-- 	util.print_table(neighbors)
	-- end
	return neighbors
end
function RoomUtils.dist_between( start, goal)
	return (math.abs(goal.x - start.x) + math.abs(goal.y - start.y))
end

function RoomUtils.hasCoordinate(table, goal)
    for index, value in ipairs (table) do
        if value.x == goal.x and value.y == goal.y then
            return true
        end
    end
    return false
end

function RoomUtils.tileToEval( coords )
	local newCoords = {}
	newCoords.x = math.ceil(coords.x/8)
	newCoords.y = math.ceil(coords.y/8)
	return newCoords
end

function RoomUtils.identifyAll(searchTable, target)
	local newTable = {}
	for k,v in pairs(searchTable) do
		for k2,v2 in ipairs(v) do
			if v2[target] then
				local newEntry = util.deepcopy(v2)
				newEntry["x"] = k
				newEntry["y"] = k2
				table.insert(newTable,newEntry)
			end
		end
	end
	return newTable
end

function RoomUtils.invertDir( dir )
	if (dir == "up") then
		return "down"
	elseif (dir == "down") then
		return "up"
	elseif (dir == "left") then
		return "right"
	elseif (dir == "right") then
		return "left"
	end
end
return RoomUtils