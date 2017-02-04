local ModCharacter = Class.create("ModCharacter", Entity)
ModCharacter.dependencies = {"ModPhysics","ModActive","ModDrawable","ModTargeter","ModCharacterDetector"}

function ModCharacter:create()
	self.noTeleportTime = 0
	self.viewDist = 240
	self.lockOnSlow = -0.4
end


---===============Animation ============---
function ModCharacter:animate()
	if self.targetObj then
		self:strafeAnimation()
	else
		self:normalAnimation()
	end
end

function ModCharacter:strafeAnimation( )
	self:orientTorwardsTarget()
	local maxSpeed, maxSpeedY = self.maxSpeedX, self.maxSpeedY
	local walkanim = math.abs(4 / self.velX)
	local newVelX = self.velX - self.referenceVelX
	local newVelY = (self.velY - self.referenceVelY) * 1.4
	local newVel = math.sqrt(math.pow(newVelX,2) + math.pow(newVelY,2))

	if self.isMovingX or self.isMovingY then
		self.idleCounter = 0
		if (self.dir == 1 and newVelX < -16) or (self.dir == -1 and newVelX > 16) then
			self:changeAnimation("walk",-0.8)
		else
			if math.abs(newVel) >= maxSpeed - 52 then
				self:changeAnimation({"run","walk"})
			else
				self:changeAnimation("walk",0.8)
			end
		end
	else
		if math.abs(newVelX) <= 32 then
			self.idleCounter = self.idleCounter + 1
			if self.idleCounter >= 60 and self.idleCounter < 89 then
				self:changeAnimation({"idleStart","idle","stand"})
			elseif self.idleCounter > 84 then
				self:changeAnimation({"idle","stand"})
			else
				self:changeAnimation("stand")
			end
		else
			self:changeAnimation({"slide","stand"})
		end
	end
	-- lume.trace(self.currentEquips)
	-- util.print_table(self.currentEquips)
	-- util.shallow_print(self.currentEquips)
	-- lume.trace(self.currentEquips["neutral"])
	-- lume.trace(self.currentEquips["neutral"].lockOnAnim)
	if self.currentEquips["neutral"] and self.currentEquips["neutral"].lockOnAnim then
		-- lume.trace(self.currentEquips["neutral"].lockOnAnim)
		-- lume.trace(self.currentEquips["neutral"].lockOnAnim)
		self:changeAnimation({ self.currentEquips["neutral"].lockOnAnim ,"aim_handgun","guard"})
	end
end

function ModCharacter:normalAnimation( )
	local maxSpeed, maxSpeedY = self.maxSpeedX, self.maxSpeedY
	local walkanim = math.abs(4 / self.velX)
	local newVelX = self.velX - self.referenceVelX
	local newVelY = (self.velY - self.referenceVelY) * 1.4
	local newVel = math.sqrt(math.pow(newVelX,2) + math.pow(newVelY,2))

	if self.isMovingX or self.isMovingY then
		self.idleCounter = 0
		if (self.dir == 1 and newVelX < -16) or (self.dir == -1 and newVelX > 16) then
			self:changeAnimation({"slideMore","slide","stand"})
		else
			if math.abs(newVel) >= maxSpeed - 52 then
				self:changeAnimation({"run","walk"})
			else
				self:changeAnimation("walk")
			end
		end
	else
		if math.abs(newVelX) <= 32 then
			self.idleCounter = self.idleCounter + 1
			if self.idleCounter >= 60 and self.idleCounter < 89 then
				self:changeAnimation({"idleStart","idle","stand"})
			elseif self.idleCounter > 84 then
				self:changeAnimation({"idle","stand"})
			else
				self:changeAnimation("stand")
			end
		else
			self:changeAnimation({"slide","stand"})
		end
	end
	if self.isHolding then
		self:changeAnimation({"holding","guard"})
	end
end

return ModCharacter