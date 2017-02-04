local ObjBase = require "ObjBase"

local FXShot = Class.create("FXShot", ObjBase)

function FXShot:init( x1,y1,x2,y2 )
	self:addModule(require "modules.ModLineFX") 
	self:setEndPoints(x1,y1,x2,y2)
end
function FXShot:create(creator, target, reticleSprite)
end

return FXShot