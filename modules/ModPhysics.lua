local ModPhysicsTD = Class.create("ModPhysicsTD", Entity)

ModPhysicsTD.trackFunctions = {"onCollide"}

function ModPhysicsTD:create()
	--set default stats
	self.deceleration = -12
	self.speedModX = 1.0
	self.speedModY = 1.0
	self.acceleration = self.acceleration or  20 * 32
	self.maxSpeedX = self.maxSpeedX or self.maxSpeed or 6 * 32
	self.maxSpeedY = self.maxSpeedY or (self.maxSpeedX * 0.6)

	--set Physics initializations
	self.dir = self.dir or 1
	self.isMoving = false
	self.isMovingX = false
	self.isMovingY = false
	self.slopeDir = 0
	self.height = self.height or 32

	--default state information
	self.forceX = 0
	self.forceY = 0
	self.velX = 0
	self.velY = 0
	self.width = self.width or 32
	self.height = self.height or 32
	self.z = 0

	self.referenceVelX = 0
	self.referenceVelY = 0
	self.created = true
	self.wrapCheckGround = lume.fn(ModPhysicsTD.mCheckGround, self)
	self.inAir = false
end

function ModPhysicsTD:tick(dt) 
	local body = self.body
	self.x,self.y = body:getPosition()
	self.velX, self.velY = body:getLinearVelocity()

	--Teleportation code. Since Set position can only be called on the tick step, the body is not
	-- moved until here.
	if self.canTeleport == true and body then
		self.canTeleport = false
		body:setPosition(self.newX, self.newY)
	end

	if not self.inAir then
		self:checkGround() -- Special code is required to handle slopes. Also needed to determine if object is on ground or not.
	end
	--Apply the body's intrinsic forces to the body
	self:move( dt, self.body, self.forceX, self.forceY, self.isMovingX, self.isMovingY)
end

function ModPhysicsTD:setSpeedModifier(modX,modY)
	modY = modY or modX
	local velX, velY = self.body:getLinearVelocity()
	self.body:setLinearVelocity(velX * modX, velY * modY)
	self.speedModX = modX
	self.speedModY = modY
end

function ModPhysicsTD:calcForce( dv, vel, accel, maxSpeed )
	local f = dv * accel-- - vel
	if math.abs( vel - self.referenceVelX) >= (maxSpeed ) and dv == util.sign( vel ) then
		f = dv * 0.000001
	end
	return f
end

function ModPhysicsTD:move( dt, body, forceX, forceY, isMovingX,isMovingY)
	local decForce = self.deceleration * body:getMass()
	local velX, velY = body:getLinearVelocity()
	-- lume.trace("type: ",self.type,"FX: ",forceX,"FY: ",forceY,isMovingX)

	--deceleration
	if (isMovingX == false or math.abs(self.velX- self.referenceVelX) > math.abs(self.maxSpeedX * self.speedModX) * 1.1) then
		if self.state == 3 then
			forceX = velX * (decForce/4)
		else
			forceX = velX * decForce
		end
	end

	if (isMovingY == false or math.abs(self.velY- self.referenceVelY) > math.abs(self.maxSpeedY * self.speedModY) * 1.1) then
		if self.slopeDir ~= 0 then
			forceY = velY * decForce * 2.5
		elseif self.state == 3 then
			forceY = velY * (decForce/4)
		else
			forceY = velY * decForce * 1.6
		end
	end

	body:setLinearVelocity(velX,velY + (velX * -self.slopeDir * 0.4))
	body:applyForce(forceX,forceY)
end

function ModPhysicsTD:createBody( bodyType ,isFixedRotation, isBullet)
	self.body = love.physics.newBody( Game.world, self.x + self.width/2, self.y+ self.height - 16, bodyType ) 
	self.body:setFixedRotation(isFixedRotation) 
	self.body:setUserData(self) 
	self.body:setBullet(isBullet)
	self.body:setGravityScale(0.0)
end

function ModPhysicsTD:setFixture( shape, mass, isSensor)
	self.x,self.y = self.body:getPosition()
	local s
	local height1 = 0
	local width1 = 0
	local topLeftX, topLeftY, bottomRightX, bottomRightY = 0,0,0,0
	if self.fixture then
		s = self.fixture:getShape()
		topLeftX, topLeftY, bottomRightX, bottomRightY = s:computeAABB( 0, 0, 0, 1 )
		height1 = math.abs(topLeftY - bottomRightY)
		width1 = math.abs(topLeftX - bottomRightY) 
		self.fixture:destroy()
	end
	topLeftX, topLeftY, bottomRightX, bottomRightY = shape:computeAABB( 0, 0, 0, 1 )
	self.height = math.abs(topLeftY - bottomRightY)
	local height2 = self.height
	local width2 = math.abs(topLeftX - bottomRightY)
	self.fixture = love.physics.newFixture(self.body, shape, 1)
	local m = mass or self.mass or 25
	self.body:setMass(m)

	local sensor = isSensor or false
	self.fixture:setSensor(sensor)
	self.fixture:setCategory(CL_CHAR)
	self.fixture:setFriction(0.01)
	self.fixture:setRestitution( 0.0 )
	self.body:setPosition(self.x, self.y - ((height2 - height1)/2))	

end

function ModPhysicsTD:setPosition(x,y)
	self.canTeleport = true
	self.newX = x
	self.newY = y
	self.x = x
	self.y = y
end

---------------------------AI Tests----------------------------
function ModPhysicsTD:testProximity(destinationX, destinationY, proximity)
	if 	self:getDistanceToPoint(destinationX,destinationY) <= proximity then
		return true
	else
		return false
	end
end

function ModPhysicsTD:getDistanceToPoint( pointX, pointY )
	return math.sqrt(math.pow(pointX - self.x,2) + math.pow(pointY - self.y,2 ) )
end

function ModPhysicsTD:getAngleToPoint(x, y)
	local angle = math.atan2(y - self.y, x - self.x)
	return angle
end

function ModPhysicsTD:turnToPoint(x, y)
	local xDiff = x - self.x
	local yDiff = y - self.y
	if math.abs(xDiff) > math.abs(yDiff) then
		if xDiff > 0 then
			self.dir = 1
		else
			self.dir = -1
		end
	else
		if yDiff > 0 then
			self.dir = 2
		else
			self.dir = 0
		end
	end
end

function ModPhysicsTD:checkGround()
	local checkGroundY = self.y + (self.charHeight or self.height) + 4
	self.numContacts = 0
	self.slopeDir = 0
	Game.world:queryBoundingBox( self.x - 3, self.y - 3, self.x + 3, self.y + 3, self.wrapCheckGround)
	self.slopeDir = math.min(math.max(self.slopeDir,-1),1)
end

function ModPhysicsTD:mCheckGround(fixture, x, y, xn, yn, fraction )
	if fixture then
		local other = fixture:getBody():getUserData()
		local category = fixture:getCategory()
		if other ~= nil and category ~= CL_INT and other ~= self  then
			self.numContacts = self.numContacts + 1
			if other.slope then
				self.slopeDir = self.slopeDir + other.slope
			end
		end
	end
	return 1
end

function ModPhysicsTD:destroy()
	-- lume.trace(self.type)
	if self.body then
		self.body:destroy()
	end
end

function ModPhysicsTD:onCollide(other, collision)
end

function ModPhysicsTD:postCollide( other, collision )
	lume.trace()
end

return ModPhysicsTD