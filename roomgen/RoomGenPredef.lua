local RoomGen = require "roomgen.RoomGen"
local RoomUtils = require "roomgen.RoomUtils"
local RoomGenPredef =  Class.create("RoomGenPredef", RoomGen)

function RoomGenPredef:init(wth,hgt,name,worldX,worldY,embelishFunct,objFunct,enemyFunct,blockFunct,predefSource)
	RoomGen.init(self,wth,hgt,name,worldX,worldY,embelishFunct,objFunct,enemyFunct,blockFunct)
	self.predefSource = "roomgen.worlds." .. predefSource
	self.mainStructType = require(self.predefSource)
	self.mainStruct = self.mainStructType(self.room,self.evalArea, self.numStructs,self)
	self.numStructs = self.numStructs + 1
	self.mainStructExits = self.predefSource.exits
end

function RoomGenPredef:generate()

	self.exits = RoomUtils.identifyAll(self.evalArea,"exit")

	self:generateMainStruct()
	self.blockPath = RoomUtils.identifyAll(self.evalArea,"filled")
	-- util.print_table(self.evalArea)
 	-- util.print_table(self.exits)
	--self:addExitStructs()
	self:linkToMainStruct()
	-- lume.trace("Successfully linked to main struct")
	local numberTries = 0
	self:identifyCornerStructs()

	self:addCorners()

	self:addExtraStructs()
	-- self:fillEmpty()
	--self:finishPaths()
	-- self.room:drawAllEdgeMaps()
	self.roomGenerated = true
	--self:finishEnemies()
end

function RoomGenPredef:generateMainStruct()
	self:addStruct( self.mainStruct , self.width/2, self.height/2)
	self.mainStructExits = {}
	-- lume.trace(self.mainStruct.exits)
	for k,v in pairs(self.mainStruct.exits) do
		local converted = {}
		converted.x = math.ceil((v.x + self.mainStruct.centX)/8)
		converted.y = math.ceil((v.y + self.mainStruct.centY)/8)

		self.evalArea[converted.x][ converted.y][v.dir] = true
		table.insert(self.mainStructExits,converted)
	end

	-- lume.trace("done with adding in converted")
	-- util.print_table(self.mainStructExits)
end


function RoomGenPredef:linkToMainStruct()
	local i = 1
	local testStart = {}
	local testEnd = {}
	-- lume.trace(table.getn(self.exits))
	local exitList = self.exits
	while i <= table.getn(self.exits) do
		-- self.corners = RoomUtils.identifyAll(self.evalArea,"corner")
		local testStart = exitList[i]
		-- lume.trace("start: ", testStart.x, testStart.y)
		local testEnd = self:closestPoint(testStart,self.mainStructExits)
		-- lume.trace("end: ", testEnd.x, testEnd.y)

		-- testStart = RoomUtils.tileToEval(nextEnd)
		-- testEnd = RoomUtils.tileToEval(closestMain)
		local original = util.deepcopy(self.evalArea)
		if testEnd.x == testStart.x and testEnd.y == testStart.y then
			lume.trace("Entrance and exit are the same, skipping")
		else
			local border = self:generateBorder(exitList)
			border = util.concat(border,self.blockPath)
			local result = RoomUtils.randomPath(testStart,testEnd,original,math.ceil(self.width/8),math.ceil(self.height/8),border, self.blockFunct)[1]
			RoomUtils.combineTables(self.evalArea ,result)
		end
		i = i + 1
	end
	-- lume.trace()
end

return RoomGenPredef