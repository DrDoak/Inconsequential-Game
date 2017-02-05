	struct:interSpaceStruct("SSHangingLight","fground","ceiling",2,0.2,nil)
	struct:interSpaceStruct("SSGroundLight","fground","ground",2,0.4,nil)
	if sType == "StHoriz" then
		if Game.genRand:random(1,2) == 1 then
			roomgen:setSubTheme(roomgen.baseTheme)
			struct:interSpaceStruct("SSBottom","bkg3","ground",nil,1.0,1)
			struct:interSpaceTile("wall_top","bkg2","ceiling",nil,1.0,nil)

			struct:interSpaceTile("wall_edge","bkg2","leftSide",nil,1.0,nil)
			struct:interSpaceTile("wall_edge","bkg2","rightSide",nil,1.0,nil, true)

			struct:interSpaceStruct( "SSBand", "bkg3","leftSide" , 2, 1.0, nil)
			struct:fillBackground("wall")
		else
			struct:interSpaceStruct("SSLowFence", "fground","ground",4,0.3,2)			
			struct:interSpaceStruct("SSFence", "fground","ground",4,0.2,2)
		end
		-- struct:interSpaceStruct("SSHangingLight","fground","ceiling",2,0.2,nil)
	elseif sType == "VtJumpsSolid" or sType == "VtStairway" or sType == "VtDrops" or sType == "VtJumpsSmall" then
		roomgen:setSubTheme("dark_building")
		if Game.genRand:random(1,2) == 1 then
			struct:interSpaceTile("baseBoard","bkg2","ground",nil,1.0,nil)
		else
			struct:interSpaceTile("curve_edge","bkg2","leftSide",nil,1.0,nil)
			struct:interSpaceTile("curve_edge","bkg2","rightSide",nil,1.0,nil, true)
		end

		struct:interSpaceStruct("SSGroundLight","fground","ground",2,0.1,nil)

		struct:interSpaceStruct("SSLightSide",{side="right"},"rightSide",4,1.0,nil)
		struct:interSpaceStruct("SSLightSide",{side="left"}, "leftSide",4,1.0,nil)
		struct:fillBackground("wall")
	elseif sType == "StVert" then
		roomgen:setSubTheme(roomgen.otherTheme)
		struct:interSpaceStruct("SSLightSide",{side="right"},"rightSide",4,1.0,nil)
		struct:interSpaceStruct("SSLightSide",{side="left"}, "leftSide",4,1.0,nil)
		struct:fillBackground("wall")
	else
		--struct:interSpaceTile("wall_top","bkg2","ceiling",nil,1.0,nil)
		--struct:interSpaceStruct("SSBottom","bkg3","ground",nil,1.0,1)
		
		struct:interSpaceStruct("SSGroundLight","fground","ground",2,0.2,nil)
		-- struct:interSpaceStruct("SSCeilingLight","fground","ceiling",2,0.2,nil)
		struct:interSpaceStruct("SSHangingLight","fground","ceiling",2,0.2,nil)

		-- struct:interSpaceStruct("SSLightSide",{side="right"},"rightSide",4,1.0,nil)
		-- struct:interSpaceStruct("SSLightSide",{side="left"}, "leftSide",4,1.0,nil)

		struct:interSpaceTile("baseBoard","bkg2","ground",nil,1.0,nil)
		struct:fillBackground("wall")
	end