local ModEnemy = Class.create("ModEnemy", Entity)
ModEnemy.dependencies = {"ModActive","ModCharacter","ModPathFinder","ModInventory"}

ModEnemy.trackFunctions = {"onAttack","onAttackStart"}

function ModEnemy:create( )
	self.aggressive = false
	self.deflectable = true

	-- self:setGoal(self.x, self.y)
	self.startX = self.x
	self.startY = self.y
	self.jumpSpeed = 210
	self.AICounter = 0
	self.AIStatus = nil
	self.timeSinceLastAttack = 0
	self.faction = "enemy"
	self.timeSinceLastJump = 0
	local function aggressiveAI( char, target )
		--self.status = "normal"
		self:moveToPoint(target.x,target.y, 64)
		self:tryAttack()
	end
	self:setRandomJumpProbability(0.01,2)
	self:setAttackFunction(aggressiveAI)
	self:setTargetPriority(30)
	if self.searchRadius then
		self.searchRadius = tonumber(self.searchRadius)
	end
end

function ModEnemy:setAttackFunction( script )
	self.attackFunct= script
end
function ModEnemy:normalState()
	-- if self == Game.tagag then
	-- end
	self.status = "normal"
	if not self.target or self.target.destroyed then
		self:findTarget()
	elseif not self.searchRadius or self:testProximity(self.target.x,self.target.y, self.searchRadius) then
		self.attackFunct(self,self.target)
	end
	self:animate()
end

function ModEnemy:tick( dt)
	self.timeSinceLastAttack = self.timeSinceLastAttack + dt
	self.timeSinceLastJump = self.timeSinceLastJump + dt

end

function ModEnemy:normalMove( )
	self:normalState()
end

function ModEnemy:setRandomJumpProbability( prob , delayBetweenJumps)
	self.randomJumpProbability = prob
	self.jumpDelay = delayBetweenJumps
end

function ModEnemy:randomJump( prob )
	if math.random() < (prob or 1) and self.timeSinceLastJump > self.jumpDelay then
		self:jump()
	end
end

function ModEnemy:setAttackRangeRate( range ,rate)
	self.attackRange = range
	self.attackRate = rate
end

function ModEnemy:tryAttack()
	local dist = self:getDistanceToPoint(self.target.x,self.target.y)
	--lume.trace(self.attackRange, self.timeSinceLastAttack,self.attackRate)
	if self.timeSinceLastAttack > self.attackRate then
		self:onAttack()
	end
end

function ModEnemy:onAttack() 
	self.timeSinceLastAttack = 0
	if self.currentEquips["neutral"] then
		self.currentEquips["neutral"]:use()
	end
end

function ModEnemy:findTarget()
	-- if self.x == 0 and self.y == 0 then return end
	local found = false
	local actList = Game:findObjectsWithModule("ModControllable")
	local minDist = 9999999
	for i,v in ipairs(actList) do
		if not self.faction or (v.faction and v.faction ~= self.faction) then
			-- lume.trace(self.x,self.y)
			local dist = self:getDistanceToPoint(v.x,v.y) 
			if dist < minDist then
				minDist = dist
				self.target = v
				found = true
			end
		end
	end
	if not found then self.target = nil end
end

function ModEnemy:setGoal( x, y ,tolerance)
	self.initX = x
	self.initY = y
	self.tolerance = tolerance or 4
end

return ModEnemy