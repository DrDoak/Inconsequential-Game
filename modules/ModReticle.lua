local ModReticle = Class.create("ModReticle", Entity)

ModReticle.dependencies = {"ModFollow","ModDrawable"}

function ModReticle:create()
	self.currentAngle = 0
end

function ModReticle:tick(dt)
	if not self.followObj or self.creator.targetObj ~= self.followObj then
		Game:del(self)
	end
	self.currentAngle = self.currentAngle + dt
	self:setSprAngle(self.currentAngle)
	if not self.creator or self.creator.destroyed then
		Game:del(self)
	end
end

function ModReticle:setCreator( creator )
	self.creator = creator
end

return ModReticle