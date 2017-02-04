-- function ModEnemy:setFrameData( startup, activeFrame, recovery)
-- 	self.startUp = startup
-- 	self.activeFrame = activeFrame or startup
-- 	self.recovery = self.startUp + (recovery or 0)
-- end

-- function ModEnemy:setAttackAnimation( animation )
-- 	if animation == "slash" then
-- 		self.preAnim = "slash_p"
-- 		self.recoveryAnim = "slash_r"
-- 	else
-- 	end
-- end

-- function ModEnemy:setSelfCanMove( canMove )
-- 	self.canMove = canMove
-- end

-- function ModEnemy:onAttackStart()
-- 	self.timeSinceLastAttack = 0
-- 	local function attackAnimation( player, frame )
-- 		if self.canMove then
-- 			player:animate()
-- 			player:normalMove()
-- 		end

-- 		if frame == 1 and self.preAnim then
-- 			player:changeAnimation(self.preAnim)
-- 		end
-- 		if frame >= self.startUp and self.recoveryAnim then
-- 			player:changeAnimation(self.recoveryAnim)
-- 		end
-- 		if frame == self.activeFrame then
-- 			self:onAttack()
-- 		elseif frame >= self.recovery then
-- 			player.exit = true
-- 		end
-- 	end
-- 	self:setSpecialState(attackAnimation)
-- end