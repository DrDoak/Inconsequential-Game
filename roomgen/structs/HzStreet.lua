local StHoriz = require "roomgen.StHoriz"
local HzStreet =  Class.create("HzStreet", StHoriz)

function HzStreet:init( room, evalArea, number, roomgen)
	StHoriz.init(self,room,evalArea, number,roomgen)
	self.structType = "HzStreet"
end

function HzStreet:makeStructure(left, top,width, height,centX,centY ,reverse )
	-- lume.trace("Making Horizontal Street")
	--lume.trace("left:",left,"top",top,"width",width,"height",height,"centX",centX,"centY",centY)
	-- self.roomgen:setSubTheme("smooth")

	-- StHoriz.makeStructure(self, left, top, width, height, centX, centY, reverse)
	-- self:interSpaceStruct( "SSPipes", "fground","ceiling" , nil, 0.2, 1)
	-- self:fillBackground("wall")
	-- -- self:interSpaceTile("window","bkg2","eyeLevel",nil, 0.2, nil)
	-- -- self:interSpaceStruct("SSLargeWindow", "bkg2","higherLevel",1,0.2,nil)
	-- -- self:interSpaceTile("sign","fground","ceiling",nil,0.2,nil)
	-- -- self:interSpaceTile("fence","fground","ground",nil,0.5,nil)
	-- -- self:interSpaceTile("baseBoard","bkg2","ground",nil,1.0,nil)
	-- self:interSpaceTile("side","bkg2","side",nil,1.0,nil)
	-- self:interSpaceStruct( "SSGroundLight", "fground","ground" , 4, 1.0, nil )
	-- self.roomgen:setSubTheme()
end

return HzStreet