local WorldGen = require "roomgen.RoomGen"
local Room = require "roomgen.Room"
local StStairs = require "roomgen.StStairs"
return function ()

 	--Game.worldManager:initWorldGen()
 	local worldHetairoi = require("roomgen.worlds.WRHetairoi")
 	Game.worldManager:setWorldGen(worldHetairoi)
 	worldHetairoi:start()
	---------------------------------

	-- local room = Room(64,64)
	-- room:addTileSet("standin")
	-- local lookUpTable = {}
	-- lookUpTable["block"] = 1
	-- lookUpTable["bkg"] = 4
	-- lookUpTable["slope"] = 2
	-- lookUpTable["slope2Bot"] = 11 
	-- lookUpTable["slope2Top"] = 12


	-- lookUpTable["corner"] = 24
	-- lookUpTable["horizontal"] = 25
	-- lookUpTable["innerCorner"] = 26
	-- lookUpTable["vertical"] = 34
	-- lookUpTable["block"] = 35

	-- room:setThemeTable(lookUpTable,"standin")
	-- local hallStructure = StStairs(room)
	-- hallStructure:setLocation(4,10)
	-- hallStructure:makeFully()
	-- room:loadRoom(10,4)

end
