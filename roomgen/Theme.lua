local Theme = Class.new{}
local RoomUtils = require "roomgen.RoomUtils"

function Theme:init(baseTable,file)
	self.subThemes = {}
	self:addSubTheme("default", baseTable,file)
end

function Theme:addSubTheme( themeName, table ,file,x,y)
	if not self.subThemes[themeName] then 
		self.subThemes[themeName] = {}
	end
	local theme = self.subThemes[themeName]
	for k,v in pairs(table) do
		if not theme[k] then theme[k] = {} end
		-- util.print_table(v)
		theme[k].id = v
		theme[k].tileset = file
	end
end

function Theme:setSubTheme( subTheme, room)
	-- lume.trace("setting sub theme")
	if not self.subThemes[subTheme] then 
		lume.trace("theme not found:" ,subTheme)
		return
	end
	for k,v in pairs(self.subThemes[subTheme]) do
		-- lume.trace(k)
		-- util.print_table(v.id)
		room:setThemeTile( v.tileset, k, v.id )	
	end
end

return Theme