local Node = require("roomgen.voronoi.Node")
local Edge = require("roomgen.voronoi.Edge")
local Graph = require("roomgen.voronoi.Graph")
local astar = require("roomgen.voronoi.astar")
-- local util = require("util")
local VoronoiSolve = {}

VoronoiSolve.weighted_voronoi_diagram  = function(graph, centers)
	lume.trace "starting Weighted Voronoi diagram"
	local distances = VoronoiSolve.construct_voronoi(graph, centers, nil)
	local meanDiff = VoronoiSolve.calculate_mean_diff(graph,#centers)

	local k=0
	local initialDistances = util.deepcopy(distances)
	local leastDifficultCenter
	repeat 
		k = k+1
		-- lume.trace("k:",k)
		leastDifficultCenter = VoronoiSolve.updateDifficulties( centers)
		-- lume.trace("leastDifficultCenter: ", leastDifficultCenter.id,"diff: " ,leastDifficultCenter.districtDifficulty)
		VoronoiSolve.updateDistances( graph, centers, initialDistances, meanDiff,distances )
		local candidates = VoronoiSolve.findMigrationCandidates(graph,centers, distances, leastDifficultCenter)
		VoronoiSolve.transferPoints(graph,candidates,leastDifficultCenter)
		-- construct_voronoi(graph, centers, migrating_candidates)
	until (#candidates==0)
	-- lume.trace("leastDifficultCenter: ", leastDifficultCenter.id)
	-- lume.trace("Mean Diff: " ,meanDiff)
	for i,v in ipairs(graph.nodeList) do
		-- lume.trace("---Node: " .. v.id)
		-- lume.trace("X: " .. v.x)
		-- lume.trace("Y: " .. v.y)
		if v.isCenter then
			-- lume.trace("I am a Center")
			-- lume.trace("difficulty = ", v.districtDifficulty)
			-- lume.trace("Num Members: ",#v.members)
		else
			-- lume.trace("Closest Center " .. v.currentClosest.id)
			-- lume.trace("distance to Center: " .. distances[v.id][v.currentClosest.id])
		end
	end
	return graph
end

function VoronoiSolve.updateDistances( graph , listCenters, initialDistances, meanDiff,distances)
	for i,node in ipairs(graph.nodeList) do
		if not node.isCenter then
			for j,center in ipairs(listCenters) do
				distances[node.id][center.id] = (center.distPrevDifficulty * initialDistances[node.id][center.id]) / meanDiff
			end
		end
	end
end

function VoronoiSolve.updateDifficulties( listCenters )
	local leastDifficultCenter = nil;
	local leastDifficultSum = 999999
	for i,center in ipairs(listCenters) do
		local total = center.mDifficulty;
		for i,v in ipairs(center.members) do
			total = total + v.mDifficulty
		end
		if total < leastDifficultSum then
			leastDifficultSum = total
			leastDifficultCenter = center
		end
		center.districtDifficulty = total
		if not center.distPrevDifficulty then
			center.distPrevDifficulty = center.districtDifficulty
		end
	end
	return leastDifficultCenter
end

function VoronoiSolve.findMigrationCandidates(graph,centers,distances, leastDifficultCenter)
	local migrationCandidates = {}
	for i,node in ipairs(graph.nodeList) do
		if not node.isCenter and node.currentClosest ~= leastDifficultCenter then
			local minDist = distances[node.id][leastDifficultCenter.id]
			local candidate = true
			for j,center in ipairs(centers) do
				if distances[node.id][center.id] < minDist then
					candidate = false
					break
				end
			end
			if candidate then table.insert(migrationCandidates,node) end
		end
	end
	return migrationCandidates	
end

function VoronoiSolve.transferPoints( graph, candidateList ,leastDifficultCenter)
	for i,candidate in ipairs(candidateList) do
		local prevCenter = candidate.currentClosest
		prevCenter.distPrevDifficulty = prevCenter.districtDifficulty
		prevCenter.districtDifficulty = prevCenter.districtDifficulty - candidate.mDifficulty
		util.deleteFromTable(prevCenter.members, candidate)

		table.insert(leastDifficultCenter.members,candidate)
		candidate.currentClosest = leastDifficultCenter
		leastDifficultCenter.distPrevDifficulty = leastDifficultCenter.districtDifficulty
		leastDifficultCenter.districtDifficulty = candidate.mDifficulty
	end
end

function VoronoiSolve.calculate_mean_diff(graph,r)
	local sum = 0
	for i,v in ipairs(graph.nodeList) do
		sum = sum+v.mDifficulty
	end
	lume.trace("sum: ", sum)
	return sum/r
end

function VoronoiSolve.construct_voronoi(graph, centers, migrating_candidates)
	local leastDifficulty = 10000000
	local leastCenter = nil;
	for j,c in ipairs(centers) do
		if c.districtDifficulty<leastDifficulty then
			leastDifficulty = c.districtDifficulty
			leastCenter = c
		end
	end

	migrating_candidates = {}

	-- for j,c in ipairs(centers) do
	-- 	c.districtDifficulty = c.districtDifficulty
	-- end

	local distances = {}
	for i,node in ipairs(graph.nodeList) do
		if (not node.isCenter) then
			local currentClosest = nil
			local minDistance = 100000
			for j,c in ipairs(centers) do
				local path = astar.path(node, c, graph)
				local pathDist = astar.calculatePathDist(path)
				if not distances[node.id] then distances[node.id] = {} end
				distances[node.id][c.id] = pathDist
				if (pathDist < minDistance) then
					minDistance = pathDist
					currentClosest = c
				end
			end
			node.currentClosest = currentClosest
			-- if (currentClosest==leastCenter) then
			-- 	table.insert(migrating_candidates, node)
			-- end
			table.insert(currentClosest.members, node)
			currentClosest.districtDifficulty = currentClosest.districtDifficulty+node.mDifficulty
		end
	end
	return distances
end

-- node1 = Node(1, 1, 0, 1,true)
-- node2 = Node(2, 2, 0, 99, false)
-- node3 = Node(3, 3, 0, 99, false)
-- node4 = Node(4, 101, 0, 1,true)

-- edge12 = Edge(node1,node2)
-- edge23 = Edge(node2,node3)
-- edge34 = Edge(node3,node4)
-- testNodeList = {node1, node2, node3, node4}
-- testGraph = Graph(testNodeList)
-- weighted_voronoi_diagram(testGraph,{node1,node4})

return VoronoiSolve