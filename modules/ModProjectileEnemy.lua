local ModProjectileEnemy = Class.create("ModProjectileEnemy", Entity)
ModProjectileEnemy.dependencies = {"ModEnemy"}

function ModProjectileEnemy:create( )
	self.aimRange = self.aimRange or 120
	local function aggressiveAI( char, target )
		--self.status = "normal"
		if char.targetObj then
			char:tryAttack()
		else
			if char:testProximity(target.x,target.y,char.aimRange) then
				char:setTarget(target)
			else
				char:moveToPoint(target.x,target.y, 64)
			end
		end
	end
	self:setAttackFunction(aggressiveAI)
end

function ModProjectileEnemy:preProcessProjectile( projectile )
	projectile.image = "assets.spr.scripts.SprEnShot"
end

function ModProjectileEnemy:setAimRange( aimRange )
	self.aimRange = aimRange
end

return ModProjectileEnemy