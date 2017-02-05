local util = require "util"
local RoomUtils = require "roomgen.RoomUtils"
local _NOOP = function () end
local bit = require "bit"
local Gamestate = require "hump.gamestate"
local Room = Class.new {}

function Room:init( wth,hgt , name)
	self.room = {}
	self.room["path"] = "assets/rooms/"
	self.room["version"] = 1.1
	self.room["name"] = name or "testRoom"
	self.room["luaversion"] = 5.1
	self.room["orientation"] = "orthogonal"
	self.room["tilewidth"] = 16
	self.room["tileheight"] = 16

	self.room["properties"] = {}
	self.properties = self.room["properties"]
	self.room["layers"] = {}
	self.layers = self.room["layers"]
	self.room["tilesets"] = {} 
	self.tilesets = self.room["tilesets"]

	self.room["width"] = wth
	self.width = wth
	self.room["height"] = hgt
	self.height = hgt

	self:addRoomProperty("minX", 0 )
	self:addRoomProperty("minY", 0)
	self:addRoomProperty("roomName", name)
	self:addRoomProperty("maxX", wth )
	self:addRoomProperty("maxY", hgt )
	-- self:addRoomProperty("use_lights","true")
	-- self:addRoomProperty("script", "BkgHetairoi" )

	self.lastGid = 1
	self.numObjectLayers = 1 
	self.numTileLayers = 1
	self:addObjectLayer(nil,"walls")
	self:addObjectLayer(nil, "Objectlayer")
	local props = {}
	props["depth"] = 9000
	self:addTileLayer(props,nil)
	props["depth"] = 9001
	self:addTileLayer(props,"edges")
	props["depth"] = 9002
	self:addTileLayer(props,"fground")
	props["depth"] = 9003
	self:addTileLayer(props, "fground2")
	props["depth"] = -5
	self:addTileLayer(props,"bkg1")
	props["depth"] = -4
	self:addTileLayer(props,"bkg2")
	props["depth"] = -3
	self:addTileLayer(props,"bkg3")


	self.lookUp = {}
	self.edgeMaps = {}
end

function Room:setSize(wth,hgt)
	self.room["width"] = wth
	self.room["height"] = hgt
end

function Room:addTileSet(imageName,width,height,properties,name)
	local newTable = {}
	newTable.name = name or imageName
	newTable.firstgid = self.lastGid
	newTable.tilewidth = 32
	newTable.tileheight = 32
	newTable.spacing = 0
	newTable.margin = 0
	newTable.image = "../tile/" .. imageName .. ".png"

	newTable.imagewidth = width or 320
	newTable.imageheight = height or 320
	newTable.transparentcolor = "#ffffff"
	newTable.tileoffset = {
        x = 0,
        y = 0
	}
	newTable.properties = properties or {}
	newTable.terrains = {}
	newTable.tilecount = (newTable.imagewidth/32) * (newTable.imageheight/32)
	-- lume.trace("Last GID: ", self.lastGid)
	-- lume.trace("last tile: ", self.lastGid + newTable.tilecount)
	-- lume.trace("adding new Image: ", newTable.image)

	self.lastGid = self.lastGid + newTable.tilecount

	newTable.tiles = {}
	table.insert(self.tilesets,newTable)
	return newTable
end

function Room:modifyTileSetProperty(tileset,key,value)
	for i,v in ipairs(self.tilesets) do
		if (v.name == tileset) then
			tileset.properties[key] = value
			break
		end
	end
end

function Room:addRoomProperty(propName,value)
	self.properties[propName] = value
end

function Room:setWorldXY( worldX,worldY )
	self.room["worldX"] = worldX
	self.room["worldY"] = worldY
end

function Room:addTileLayer(properties,name)
	local newLayer = {}
	newLayer.type = "tilelayer"
	newLayer.name = name or ("TileLayer " .. self.numTileLayers)
	self.numTileLayers = self.numTileLayers + 1
	newLayer.x = 0
	newLayer.y = 0
	newLayer.width = self.room["width"]
	newLayer.height = self.room["height"]
	newLayer.visible = true
	newLayer.opacity = 1
	newLayer.offsetx = 0
	newLayer.offsety = 0
	if properties then
		newLayer.properties = util.deepcopy(properties)
	else
		newLayer.properties = {}
	end
	newLayer.encoding = "lua"
	newLayer.data = {}
	for i=1,newLayer.width do
		for j=1,newLayer.height do
			table.insert(newLayer.data,0)
		end
	end
	table.insert(self.layers,newLayer)
end

function Room:modifyLayerProperty(layer,key,value)
	for i,v in ipairs(self.layers) do
		if (v.name == layer) then
			tileset.properties[key] = value
			break;
		end
	end
end

function Room:addObjectLayer(properties,name)
	local newLayer = {}
	newLayer.type = "objectgroup"
	newLayer.name = name or ("Objectlayer " .. self.numObjectLayers)
	self.numObjectLayers = self.numObjectLayers + 1
	newLayer.width = self.room["width"]
	newLayer.height = self.room["height"]
	newLayer.visible = true
	newLayer.opacity = 1
	newLayer.offsetx = 0
	newLayer.offsety = 0
	newLayer.properties = properties or {}
	newLayer.encoding = "lua"
	newLayer.objects = {}
table.insert(self.layers,newLayer)
end

function Room:setTile( layer,x,y,tile,flipX,flipY) --NOTE!: We start at 0,0 in coordinates
	local destLayer = layer or "TileLayer 1"
	for i,v in ipairs(self.layers) do
		-- lume.trace("in tile loop")
		if (v.name == destLayer) then
			local index = (y + 1) * self.width + x + 1
			if (type(tile) == "number") then
				-- lume.trace("setting tile")
				v.data[index] = tile 
			elseif (type(tile) == "table") then
				-- util.print_table(tile)
				v.data[index] = tile[math.random(1,table.getn(tile))]
			elseif self.lookUp then
				local num = self.lookUp[tile] or 0
				if (type(num) == "table") then
					num = num[math.random(1,table.getn(num))]
				end
				v.data[index] = num 
			end
			if flipX then
				v.data[index] = bit.tobit((bit.bor(v.data[index], 2^31)))
			end
			if flipY then
				v.data[index] = bit.bor(v.data[index], 2^30)
			end
			v.data[index] = (v.data[index])
		end
	end
end

function Room:getTile( layer,x,y)
	local destLayer = layer or "TileLayer 1"
	for i,v in ipairs(self.layers) do
		if (v.name == destLayer) then
			local index = (y + 1) * self.width + x + 1
			return v.data[index]
		end
	end
end
function Room:tileMatch( tile1,tileType )
	if tile1 == nil then
		return false
	end
	local eval = false
	local realTile = self.lookUp[tileType]
	if type(realTile) == "table" then
		for i,v in ipairs(realTile) do
			--lume.trace(v)
			eval = self:tileEqual(tile1, v)
			if eval then
				return eval
			end
		end
	else
		eval = self:tileEqual(tile1, realTile)
		return eval
	end
	return false
end
function Room:tileEqual( tile,testObject)
	-- local destLayer = layer or "TileLayer 1"
	-- y = 1 * y
	-- if (x > self.width) or (1 *y > self.height) or  x < 1 or y < 1 then
	-- 	return false
	-- end
	-- for i,v in ipairs(self.layers) do
	-- 	if (v.name == destLayer) then
	-- 		local index = (y + 1) * self.width + x + 1
	-- 		if not v.data[index] then
	-- 			return false
	-- 		end
	-- 		local evaluate = testObject
	-- 		if type(testObject) ~= "number" and self.lookUp then
	-- 			evaluate = self.lookUp[testObject] or 0
	-- 		end
	-- 		if (v.data[index] == evaluate) then return "equal" end
	-- 		local newEval = bit.tobit((bit.bxor(v.data[index], 2^31)))
	-- 		if (newEval == evaluate) then return "flipX" end
	-- 		newEval = bit.tobit((bit.bxor(v.data[index], 2^30)))
	-- 		if (newEval == evaluate) then return "flipY" end
	-- 		return false
	-- 	end
	-- end
	if (tile == testObject) then return "equal" end
	-- lume.trace(tile)
	local newEval = bit.tobit((bit.bxor(tile, 2^31)))
	if (newEval == testObject) then return "flipX" end
	newEval = bit.tobit((bit.bxor(tile, 2^30)))
	if (newEval == testObject) then return "flipY" end
	return false
end

function Room:setThemeTable(table,tilesetID)
	table = util.deepcopy(table)
	if tilesetID then
		for i,v in ipairs(self.tilesets) do
			if (v.name == tilesetID) then
				local offsetGID = v.firstgid - 1
				for k,v in pairs(table) do
					if type(v) == "table" then
						for i2,v2 in ipairs(v) do
							table[k][i2] = v2 + offsetGID
						end
					else
						table[k] = v + offsetGID
					end
				end
				self.lookUp = table
			end
		end
	else
		self.lookUp = table
	end
	self.lookUp = table
	--util.print_table(self.lookUp)
end

function Room:setThemeTile( tileset, name, gid )	
	local offsetGID = 0
	local found = false
	for i,v in ipairs(self.tilesets) do
		if (v.name == tileset) then
			offsetGID = v.firstgid - 1
			found = true
		end
	end
	if found == false then
		offsetGID = self:addTileSet(tileset,320,320).firstgid - 1
	end
	if type(gid) == "table" then
		self.lookUp[name] = {}
		for i2,v2 in ipairs(gid) do
			self.lookUp[name][i2] = v2 + offsetGID
		end
	else
		self.lookUp[name] = gid + offsetGID
	end
end

function Room:addRectangleObj(type,x,y,width,height,properties,layer,name)
	--lume.trace("adding rectangle Object of type: " , type)
	--lume.trace("X: ", x , "Y: ", y , "Width: ", width, "Height: ", height, "layer: ", layer)
	local newObj = {}
	newObj.name = name or ""
	newObj.type = type
	newObj.shape = "rectangle"
	newObj.x = x * 16
	newObj.y = y * 16
	newObj.width = width * 16
	newObj.height = height * 16
	newObj.properties = properties or {}
	newObj.visible = true
	local destLayer = layer or "Objectlayer"
	for i,v in ipairs(self.layers) do
		--lume.trace("Name: ", v.name)
		if (v.name == destLayer) then
			table.insert(v.objects,newObj)
			break
		end
	end
end

function Room:addPolyline(type,x,y,polyline,properties,layer,name)
	local newObj = {}
	newObj.name = name or ""
	newObj.type = type
	newObj.shape = "polyline"
	newObj.x = x
	newObj.y = y
	newObj.width = 0
	newObj.height = 0
	newObj.properties = properties or {}
	newObj.visible = true
	newObj.polyline = polyline
	local destLayer = layer or "ObjectlaynewObjer 1"
	for i,v in ipairs(self.layers) do
		if (v.name == destLayer) then
			table.insert(v.objects,newObj)
			break
		end
	end
end

function Room:addWall(x,y,polyline,jumpThru,stairs)
	local props = {}
	props["jumpThru"] = jumpThru
	props["isStairs"] = stairs
	self:addPolyline("ObjWall",x,y,polyline,props,"walls", nil)
end

function Room:addJumpThru( polyline )
	-- body
end

function Room:addWallLink( polyline,fillBottom,themeTable,tileset,jumpThru, stairs)
	self:addWall(0,0,polyline,jumpThru,stairs) 
end
function Room:addSlopes( polyline,fillBottom,themeTable,tileset,jumpThru, stairs)
	self:addWall(0,0,polyline,jumpThru,stairs) 
	-- util.print_table(polyline)
	local length = table.getn(polyline)
	local minXIndex = 0
	local maxY = 0
	for i,v in ipairs(polyline) do
		maxY = math.max(maxY,v.y)
	end
	local index = 1
	local edgeTiles = {}
	while index < (length) do 
		local currCoord = polyline[index] -- Initialize current Coordinate and next
		local nextCoord = polyline[index + 1]
		local dx = (nextCoord.x - currCoord.x)
		local dy = (nextCoord.y - currCoord.y)
		local ratio = dy/dx
		if ratio == 0 then --flat
			local x = currCoord.x
			while (x < nextCoord.x) do
				local index = (x/16) .. " " .. (currCoord.y/16)
				-- self:setTile(nil,x,currCoord.y,"block")
				edgeTiles[index] = {}
				if jumpThru then
					self:setTile("edges",x/16,currCoord.y/16,"jumpThru")
				else
					self:setTile("edges",x/16,currCoord.y/16,"horizontal")
					edgeTiles[index]["block"] = true
				end
				if fillBottom then
					local botY = currCoord.y
					while (botY <= maxY) do
						index = (x/16) .. " " .. (botY/16)
						edgeTiles[index] = {}
						edgeTiles[index]["block"] = true
						botY = botY + 32
					end
				end
				if dx > 0 then
					x = x + 32
				else
					x = x - 32
				end
			end
		elseif math.abs(ratio) == 0.5 then -- low slope
			local botSlope
			if dy > 0 then
				botSlope = false
			else
				botSlope = true
			end
			local x = currCoord.x
			local y = currCoord.y
			-- util.print_table(currCoord)
			-- lume.trace(x)
			-- lume.trace(y)
			while (x < nextCoord.x) do
				local nextx, nexty, flipX, flipY
				nexty = y
				if dx > 0 then
					flipX = true
					nextx = x + 32
				else
					nextx = x - 32
				end
				if dy > 0  then
					if botSlope then
						nexty = y + 32
						self:setTile("edges",x/16,y/16,"slope2Bot",flipX)
					else
						self:setTile("edges",x/16,y/16,"slope2Top",flipX)
					end
				else
					flipX = not flipX
					if botSlope then
						self:setTile("edges",x/16,(y/16) - 2,"slope2Bot",flipX)
					else
						nexty = y - 32
						self:setTile("edges",x/16,(y/16) - 2,"slope2Top",flipX)
					end
				end
				if fillBottom then
					local botY = y
					local first = true
					if (dy < 0) then botY = y else botY = y + 32 end
					while (botY <= maxY) do 
						local index = (x/16) .. " " .. (botY/16)
						edgeTiles[index] = {}
						edgeTiles[index]["block"] = true
						if first == true then
							if botSlope then
								self:setTile("edges",x/16,(botY/16),"slope2Top", not flipX,true)
							else
								self:setTile("edges",x/16,(botY/16),"slope2Bot", not flipX,true)
							end
							first = false
						end
						botY = botY + 32
					end
				end
				x = nextx
				y = nexty
				botSlope = not botSlope
			end
		elseif math.abs(ratio) == 1.0 then -- steep slope
			local x = currCoord.x
			local y = currCoord.y
			while (x < nextCoord.x) do
				local nextx, nexty, flipX, flipY
				nexty = y
				if dx > 0 then
					flipX = true
					nextx = x + 32
				else
					nextx = x - 32
				end
				if dy > 0 then
					nexty = y + 32
					self:setTile("edges",x/16,y/16,"slope",flipX)
				else
					flipX = not flipX
					nexty = y - 32
					self:setTile("edges",x/16,(y/16) - 2,"slope",flipX)
				end
				if fillBottom then
					local botY = y
					local first = true
					if (dy < 0) then botY = y else botY = y + 32 end
					while (botY <= maxY) do 
						local index = (x/16) .. " " .. (botY/16)
						edgeTiles[index] = {}
						edgeTiles[index]["block"] = true
						if first == true then
							self:setTile("edges",x/16,(botY/16),"slope", not flipX,true)
							first = false
						end
						botY = botY + 32
					end
				end
				x = nextx
				y = nexty
			end
		else
			util.print_table(polyline)
			lume.trace(ratio)
			error("Bad slope with ratio of ", ratio)
			lume.trace("WARNING: attempting to draw invalid slope with ratio: ", ratio)
		end
		index = index + 1
	end
	local enclosedObject = {}
	enclosedObject.data = edgeTiles
	enclosedObject.themeTable = themeTable
	enclosedObject.tileset = tileset
	table.insert(self.edgeMaps,enclosedObject)
end

function Room:addEnclosedArea(polyline,themeTable,tileset)
	-- lume.trace("+++++++++++++++")
	local newPolyLine = util.deepcopy(polyline)
	table.insert(newPolyLine,polyline[1])
	self:addWall(0,0,newPolyLine,false) 
	local length = table.getn(polyline)
	local minYIndex = 1
	local minHeight = 9999
	local minY = polyline[1].y
	local minX = polyline[1].x
	local maxY = polyline[1].y
	local maxX = polyline[1].x
	local currentBlock = self.lookUp["block"]
	for i,v in ipairs(polyline) do
		-- lume.trace('eval')
		-- lume.trace(v.y < minHeight)
		-- lume.trace(i < length)
		-- lume.trace(v.x)
		-- util.print_table(polyline[i+1])
		if (v.y < minHeight and i < length and polyline[i+1].x ~= v.x) then
			minYIndex = i
			minHeight = v.y
		end
		minY = math.min(minY,v.y)
		minX = math.min(minX,v.x)
		maxY = math.max(maxY,v.y)
		maxX = math.max(maxX,v.x)
	end
	if table.getn(polyline) == 4 and maxX - minX == 32 and maxY - minY == 32 then
		-- lume.trace("X: ", minX, "Y: ", minY)
		-- lume.trace("X: ", minX/16, "Y: ", minY/16)
		self:setTile("edges",minX/16,minY/16,"blockSingle")
		return
	end
	-- lume.trace("min y index:" ,minYIndex)
	local numVisited = 0
	local edgeTiles = {}
	local currIndex = minYIndex

	local prevSide = false
	local prevDir  = false
	local currDir = false
	local currSide = "up"

	-- First, mark all Edge columns
	-- util.print_table(polyline)
	while numVisited <= length do 
		local currCoord = polyline[currIndex] -- Initialize current Coordinate and next

		local nextCoord = {}
		if currIndex == length then
			nextCoord = polyline[1]
			currIndex = 1
		else
			nextCoord = polyline[currIndex + 1]
			currIndex = currIndex + 1
		end
		--Calculate the current direction of the vector
		if nextCoord.y == currCoord.y then --A horizontal strip
			if nextCoord.x > currCoord.x then
				currDir = "right"
			else
				currDir = "left"
			end
		elseif nextCoord.x == currCoord.x then --A vertical strip
			if nextCoord.y < currCoord.y then
				currDir = "up"
			else
				currDir = "down"
			end
		end
		--Calcualte which "Face" this thing is.
		if (prevSide) then --Calculate
			local cond1 = (prevSide == RoomUtils.invertDir(currDir))
			-- lume.trace(cond1)
			-- lume.trace(prevSide)
			-- lume.trace(self.invertDir(currDir))
			if (cond1) then --"Outer corner"
				currSide = prevDir
				self:updateEdgeTable(currCoord.x,currCoord.y,prevSide,currSide,edgeTiles,true)
				self:updateEdgeTable(currCoord.x,currCoord.y,currSide,prevSide,edgeTiles,true)
			else --"Inner corner"
				-- lume.trace("inner corner")
				-- lume.trace(prevDir)
				-- lume.trace(currDir)
				currSide = RoomUtils.invertDir(prevDir)
				self:updateEdgeTable(currCoord.x,currCoord.y,prevSide,prevSide,edgeTiles,true)
				self:updateEdgeTable(currCoord.x,currCoord.y,currSide,currSide,edgeTiles,true)

				self:updateEdgeTable(currCoord.x,currCoord.y,prevSide,currSide,edgeTiles,true)
				local index = self:updateEdgeTable(currCoord.x,currCoord.y,currSide,prevSide,edgeTiles,true)
				edgeTiles[index]["innerCorner"] = true
				-- self:updateEdgeTable(currCoord.x,currCoord.y,"innerCorner",currSide,edgeTiles,true)
			end
			if numVisited == length then
				break;
			end
		else
			currSide = "up"
		end
		
		--Fill in the rest of the tiles in between the corners
		if nextCoord.y == currCoord.y then --A horizontal strip
			local currPoint = currCoord.x
			if nextCoord.x > currCoord.x then
				while(currPoint < nextCoord.x) do
					if (currPoint ~= currCoord.x) then
						self:updateEdgeTable(currPoint,currCoord.y,currSide,prevSide,edgeTiles)
					end
					currPoint = currPoint + 32
				end
			else
				while(currPoint > nextCoord.x) do
					if (currPoint ~= currCoord.x) then
						self:updateEdgeTable(currPoint,currCoord.y,currSide,prevSide,edgeTiles)
					end
					currPoint = currPoint - 32
				end
			end
		elseif nextCoord.x == currCoord.x then --A vertical strip
			local currPoint = currCoord.y
			if nextCoord.y > currCoord.y then
				while(currPoint < nextCoord.y) do
					if (currPoint ~= currCoord.y) then
						self:updateEdgeTable(currCoord.x,currPoint,currSide,prevSide,edgeTiles)
					end
					currPoint = currPoint + 32
				end
			else
				while(currPoint > nextCoord.y) do
					if (currPoint ~= currCoord.y) then
						self:updateEdgeTable(currCoord.x,currPoint,currSide,prevSide,edgeTiles)
					end
					currPoint = currPoint - 32
				end
			end
		end
		prevDir = currDir
		prevSide = currSide
		numVisited = numVisited + 1
	end

	local iterX = minX
	local iterY = minY

	local isBlock = false
	while (iterX < maxX) do
		while (iterY <= maxY) do
			local index = (iterX/16) .. " " .. (iterY/16)
			if edgeTiles[index] then
				edgeTiles[index]["block"] = currentBlock
				if edgeTiles[index]["up"] and not edgeTiles[index]["innerCorner"] then
				 	isBlock = not isBlock
				end
				if edgeTiles[index]["down"] and not edgeTiles[index]["innerCorner"] then
					isBlock = not isBlock
				end
			else
				if (isBlock) then
					edgeTiles[index] = {}
					edgeTiles[index]["block"] = currentBlock
				end
			end
			iterY = iterY + 32
		end
		isBlock = false
		iterY = minY
		iterX = iterX + 32
	end
	--util.print_table(edgeTiles)

	local enclosedObject = {}
	enclosedObject.data = edgeTiles
	enclosedObject.themeTable = themeTable
	enclosedObject.tileset = tileset
	table.insert(self.edgeMaps,enclosedObject)
	-- Then iterate through all remaining things in the boundary box and fill in
end

function Room:updateEdgeTable( x,y,currSide,prevSide ,edgeTiles,corner)
	local cX = x/16
	if (currSide ~= "left" and (currSide == "right" or (corner and prevSide == "right"))) then cX = cX - 2 end
	local cY = y/16
	if (currSide ~= "up" and (currSide == "down" or (corner and prevSide == "down"))) then cY = cY - 2 end
	local index =  cX .. " " .. cY
	local currIndexTable = edgeTiles[index] or {}
	currIndexTable[currSide] = true-- self.lookUp[currSide]
	edgeTiles[index] = currIndexTable
	return index
end

function Room:drawAllEdgeMaps()
	--Step 1: Fill in all blocks and edge blocks
	for i,enclosedObj in ipairs(self.edgeMaps) do
		if enclosedObj.themeTable then
			self:setThemeTable(enclosedObj.themeTable,enclosedObj.tileset)
		end
		for k,v in pairs(enclosedObj.data) do
			local coords = {}
			for i in string.gmatch(k, "%S+") do
  				table.insert(coords,i)
  			end
  			if v["block"] then
  				-- lume.trace(coords[1],coords[2])
  				-- util.print_table(self.lookUp["block"])
  				-- util.print_table(self.lookUp["horizontal"])
				self:setTile(nil,coords[1],coords[2],v["block"])
			end
			local cornerType
			if v["innerCorner"] then
				cornerType = "innerCorner"
			else
				cornerType = "corner"
			end
			--self:setEdge(coords[1],coords[2],v,cornerType)
		end
	end
	--Step 2: Resolve Merging issues between structures
	for i,enclosedObj in ipairs(self.edgeMaps) do
		if enclosedObj.themeTable then
			self:setThemeTable(enclosedObj.themeTable,enclosedObj.tileset)
		end
		for k,v in pairs(enclosedObj.data) do
			local coords = {}
			for i in string.gmatch(k, "%S+") do
  				table.insert(coords,i)
  			end
  			if v["block"] then
				self:setTile(nil,coords[1],coords[2],v["block"])
			end
			local cornerType
			if v["innerCorner"] then
				cornerType = "innerCorner"
			else
				cornerType = "corner"
				if (v["up"] or v["down"]) then		
					if (self:tileMatch(self:getTile("TileLayer 1",coords[1] ,coords[2]+2), "block") and
						self:tileMatch(self:getTile("TileLayer 1",coords[1] ,coords[2]-2), "block")) then
						v["up"] = nil
						v["down"] = nil
					end
				end
				if (v["left"] or v["right"]) then
					if (self:tileMatch(self:getTile("TileLayer 1",coords[1]+2,coords[2]), "block") and
						self:tileMatch(self:getTile("TileLayer 1",coords[1]-2,coords[2]), "block")) then
						local mod = false
						local leftVal = self:tileMatch(self:getTile("edges",coords[1]+2,coords[2]),"horizontal")
						local rightVal = self:tileMatch(self:getTile("edges",coords[1]+2,coords[2]),"horizontal")
						if not mod then
							v["left"] = nil
							v["right"] = nil
						end
					end
				end
			end
			self:setEdge(coords[1],coords[2],v,cornerType)
		end
	end
end

function Room:setEdge(x,y,v,cornerType)
	if (v["up"]) then
		if v["left"] then
			self:setTile("edges",x,y,cornerType)
		elseif v["right"] then
			self:setTile("edges",x,y,cornerType,true)
		else
			self:setTile("edges",x,y,"horizontal")
		end
	elseif (v["down"]) then
		if v["left"] then
			self:setTile("edges",x,y,cornerType,nil,true)
		elseif v["right"] then
			self:setTile("edges",x,y,cornerType,true,true)
		else
			self:setTile("edges",x,y,"horizontal",nil,true)
		end
	elseif (v["left"]) then
		self:setTile("edges",x,y,"vertical")
	elseif (v["right"]) then
		self:setTile("edges",x,y,"vertical",true)
	end
end

function Room:getRoom()
	return self.room
end

function Room:loadRoom(plyrX,plyrY)
	local player = Game.player
	local x,y = player.body:getPosition()
	local newX = plyrX and tonumber(plyrX)* 16 or x
	local newY = plyrY and tonumber(plyrY) * 16 or y
	player:setPosition( newX, newY )
	--Gamestate.push( FadeState, {0,0,0,0}, {0,0,0,255},0.3)
	Game:loadRoom(self:getRoom())

	-- local newX = 20 and tonumber(20)* 16 or x
	-- local newY = 18 and tonumber(18) * 16 or y
	-- player:setPosition( newX, newY )
	-- Game:loadRoom("assets/rooms/MRForlorn")
	--Gamestate.pop()
end

return Room