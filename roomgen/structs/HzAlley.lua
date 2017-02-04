local StHoriz = require "roomgen.StHoriz"
local HzAlley =  Class.create("HzAlley", StHoriz)

function HzAlley:init( room, evalArea, number)
	StHoriz.init(self,room,evalArea, number)
	self.structType = "HzAlley"
	-- lume.trace("Creating Alley Object!!")
end

function HzAlley:makeStructure(left, top,width, height,centX,centY ,reverse )
	--lume.trace("Making Horizontal Alley")
	self.roomGen:setSubTheme("smooth")
	StHoriz.makeStructure(self, left, top, width, height, centX, centY, reverse)
	self:interSpaceTile( "fence", "fground","ground" , nil, 0.9, nil )
	self:fillBackground("wall")d
	self.roomGen:setSubTheme()

end

return HzAlley