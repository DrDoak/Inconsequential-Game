local ModMeleeEnemy = Class.create("ModMeleeEnemy", Entity)
ModMeleeEnemy.dependencies = {"ModEnemy"}

function ModMeleeEnemy:create( )
	self.meleeRange = self.meleeRange or 8
	local function aggressiveAI( char, target )
		if char:testProximity(target.x,target.y,char.meleeRange * 2) then
			self:tryAttack()
		else
			char:moveToPoint(target.x,target.y, 8)
		end
	end
	self:setAttackFunction(aggressiveAI)
end

function ModMeleeEnemy:setAimRange( aimRange )
	self.aimRange = aimRange
end

return ModMeleeEnemy