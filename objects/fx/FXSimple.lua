local ObjBase = require "ObjBase"
local FXSimple = Class.create("FXSimple", ObjBase)

function FXSimple:init(posX , posY, creator, timer)
	self.x = posX
	self.y = posY
	self.creator = creator
	self.timer = timer
end


function FXSimple:create()
	self:addModule(require "modules.ModDrawable")
	self:addModule(require "modules.ModFollow")
	self:addModule(require "modules.ModFX")
	self:setColor()
end

return FXSimple