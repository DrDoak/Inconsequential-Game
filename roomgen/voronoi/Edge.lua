-- local Class = require("class")
local Edge = Class.create("Edge", Entity)

function Edge:init(node1, node2, weight)
	self.vi = node1
	node1:addNeighbor(node2,self)
	self.vj = node2
	node2:addNeighbor(node1,self)

	self.weight = weight or math.abs ( node2.x - node1.x) + math.abs ( node2.y - node1.y )
	-- math.sqrt(math.pow(node2.x - node1.x,2) + math.pow(node2.y - node1.y,2 ) ) 
end

function Edge:calculatePerturbed(epsilon)
	self.perturbedLength = self.weight + math.pow(epsilon, self.id+1)
end

return Edge