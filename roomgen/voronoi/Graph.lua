-- local Class = require("class")
local Graph = Class.create("Graph", Entity)

function Graph:init(NodeList)
	self.nodeList = NodeList
end

return Graph