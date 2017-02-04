local StVert = require "roomgen.StVert"
local VtPlatforms =  Class.create("VtPlatforms", StVert)

function VtPlatforms:init( room, evalArea, number,roomgen)
	StVert.init(self,room,evalArea, number,roomgen)
	self.structType = "VtPlatforms"
end

function VtPlatforms:makeStructure(left, top,width, height,centX,centY ,reverse )
	lume.trace("Making Horizontal Street")
	--lume.trace("left:",left,"top",top,"width",width,"height",height,"centX",centX,"centY",centY)
	StVert.makeStructure(self, left, top, width, height, centX, centY, reverse)
	self:interSpaceTile( "fence", "fground","ground" , nil, 0.9, nil )
end

return VtPlatforms