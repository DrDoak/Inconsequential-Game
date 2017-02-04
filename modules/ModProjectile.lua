local ModProjectile = Class.create("ModProjectile", Entity)
local ObjDamageHitbox = require "objects.ObjDamageHitbox"
ModProjectile.dependencies = {"ModPhysics","ModDrawable"}
ModProjectile.trackFunctions = {"onPin"}

function ModProjectile:create()
	self.referenceVel = 0
	self.angle = 0
	self.objectsHit = {}
	self.tickFuncts = {}
	self.destroyFuncts ={}
	self.hitFuncts = {}
	self.dir = 1--self.attacker.dir
	self.speed = self.speed or 5 * 32
	self.vHeight = self.vHeight or 0
end

function ModProjectile:fireAtPoint( pointX,pointY,speed )
	local ang = self:getAngleToPoint(pointX,pointY)
	self:setSprAngle(ang)
	self:setInitialVelocity(speed * math.cos(ang),speed * math.sin(ang))
end

function ModProjectile:setInitialVelocity( initX,initY )
	self.iVelX = initX or 0
	self.iVelY = initY or 0
	self.initialVelocity = true
end

function ModProjectile:setFaction( faction )
	self.faction = faction
end

function ModProjectile:setVHeight( vHeight )
	self.vHeight = vHeight or 0
end

function ModProjectile:addTickFunction( funct )
	table.insert(self.tickFuncts,funct)
end

function ModProjectile:addDestroyFunction( funct )
	table.insert(self.destroyFuncts,funct)
end

function ModProjectile:addOnHitFunction( funct )
	table.insert(self.hitFuncts,funct)
end

function ModProjectile:tick( dt )

	if not self.syncHitboxes then
		self.syncHitboxes = true
		self.hb = ObjDamageHitbox(self, self.damage, self.stun, self.refresh, self.forceX, self.forceY, self.element, self.ignoreType)
		Game:add(self.hb)
	end
	if self.initialVelocity then
		self.body:setLinearVelocity(self.iVelX,self.iVelY)
		--self.initialVelocity = false
	end
	--self.sprite:setScale(self.dir * 1,1)

	if self.deflected then
		self:deflectState()
	else
		self:normalState()
	end

	if self.stopOnPin and self.stopOnPin == "wall" then
		self:onPin()
		self.stopOnPin = nil
	end

	if self.range then
		self.range = self.range - 1
		if self.range <= 0 then
			Game:del(self)
		end
	end
end

function ModProjectile:deflectState()
	if self.deflectTime == 60 then
		self.body:setLinearVelocity(math.random(32, 64) * self.defDir, math.random(-3 * 32, -6 * 32))
	end
	self.deflectTime = self.deflectTime - 1
	if self.deflectTime <= 0 then
		Game:del(self)
	end
end

function ModProjectile:normalState() 
	if self.tickFuncts then
		for i,v in ipairs(self.tickFuncts) do
			v(self)
		end
	end
end

function ModProjectile:moveToPoint(destinationX, destinationY, proximity, velocity)
	local distance = math.sqrt(((destinationX - self.x) * (destinationX - self.x)) +
		((destinationY - self.y) * (destinationY - self.y)))
	local angle = self:getAngleToPoint(destinationX, destinationY)
	if proximity and distance <= proximity then
		self.body:setLinearVelocity(0, 0)
	else
		local moveX = math.cos(angle) * velocity
		local moveY = math.sin(angle) * velocity
		self.body:setLinearVelocity(moveX, moveY)
	end
end

function ModProjectile:setHitState(stunTime, forceX, forceY, damage, element,faction,hitbox)
	local st = stunTime or 0
	local dm = damage or 0
	local x, y = self.attacker.body:getPosition()
	if faction and self.faction and self.faction == faction then
		return false
	else
		if st > 0 then 
			self.state = 3 
			if self.hitRow then
				self:changeAnimation(self.hitRow, self.hitFrame, 0, self.hitFrame)
			else
				self:changeAnimation(1,self.hitFrame,0, self.hitFrame)
			end
		end
		self.stun = st
		Log.verbose("stun set to : " .. self.stun)
		self.health = self.health - dm
		Log.verbose("health = " .. self.health)
		self.body:applyLinearImpulse(forceX, forceY)
		lume.trace()
		return true
	end
end

function ModProjectile:onCollide(other, collision)
	if Class.istype(other, "ObjWall") then
		self:onHitWall()
		if self.stopOnPin then
			self.stopOnPin = "wall"
			self.pinned = true
		end
	end
	
end

function ModProjectile:onPin()
	if Class.istype(self.hb,"ObjDamageHitbox") then
		self.hb:setActive(false)
	else
		self.hb:setPersistence(0)
	end
	self.body:setLinearVelocity(0,0)
	self.body:setType("kinematic")
end

function ModProjectile:onHitWall() end

function ModProjectile:onHitConfirm(target, hitType, hitbox)
	self.range = 0
	if self.attacker and not self.attacker.destroyed then
		self.attacker:onHitConfirm(target,hitType,hitbox)
	end
	if self.hitFuncts then
		for i,v in ipairs(self.hitFuncts) do
			v(self,target,hitType,hitbox)
		end
	end
end

function ModProjectile:destroy()
	if self.destroyFuncts then
		for i,v in ipairs(self.destroyFuncts) do
			v(self)
		end
	end
end

function ModProjectile:setDeflectState(stunTime, forceX, forceY, damage, element,faction)
	if faction and self.faction and self.faction == faction then
		return false
	elseif not self.deflected then	
		self.hb.persistence = 0
		self.body:setGravityScale(1.0)
		self.deflected = true
		if forceX > 0 then
			self.defDir = 1
		else
			self.defDir = -1
		end
		self.deflectTime = 60
		return true
	end
	return false
end

function ModProjectile:setTarget( target )
	self.targetType = target
end

function ModProjectile:checkEn(fixture)
	if fixture then
		local other = fixture:getBody():getUserData()
		if other and Class.istype(other, self.targetType) then
			local dist = other:getDistanceToPoint(self.x, self.y)
			if dist < self.minDistance then
				self.minDistance = dist
				self.target = other
			end
		end
	end
	return 1
end

function ModProjectile:decForce( dt, body)
	local body = self.body
	local decForce = self.deceleration * self.body:getMass()
	local velX, velY = body:getLinearVelocity()
	local forceX, forceY
	forceX = 0
	forceY = 0

	-- decceleration
	if not self.inAir and ( not self.maxSpeed or (math.abs(self.velX- self.referenceVel) > math.abs(self.maxSpeed) * 1.1)) then
	 	forceX = velX * decForce
	end
	body:applyForce(forceX,forceY)
end


return ModProjectile