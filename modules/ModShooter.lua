local ModShooter = Class.create("ModShooter", Entity)
local ObjShot = require "objects.ObjShot"

ModShooter.trackFunctions = {"onAttack","preProcessProjectile","postProcessProjectile"}

function ModShooter:onAttack(goalX,goalY,vHeight)
	self:shoot(goalX,goalY,vHeight)
end

function ModShooter:shoot(goalX,goalY,vHeight)
	local xSpawn = self.x - 16
	local ySpawn = self.y - 20
	if self.dir == -1 or self.dir == 1 then
		self.x = self.x + (14 * self.dir)
	end
	local newShot = ObjShot(self.x - 16,ySpawn,self)
	self:preProcessProjectile(newShot)
	if self.user and self.user.preProcessProjectile then
		self.user:preProcessProjectile(newShot)
	end
	Game:add(newShot)
	newShot:fireAtPoint(goalX,goalY,newShot.speed)
	newShot:setVHeight(vHeight)
	newShot:addShadow("circle",16,8)

	self:postProcessProjectile(newShot)
	if self.user and self.user.postProcessProjectile then
		self.user:postProcessProjectile(newShot)
	end
end

function ModShooter:preProcessProjectile( projectile )
end

function ModShooter:postProcessProjectile( projectile )
end

function ModShooter:onDeath()
end

return ModShooter