if targetObj then
		targetX = targetObj.x
		targetY = targetObj.y
		angle = self:getAngleToPoint(targetX,targetY)
		if math.random() > self.accuracy then
			directHit = false
			local perpOff = math.random(1,2)
			if perpOff == 2 then
				perpOff = perpOff - 3
			end
			perpOff = perpOff * math.random(8,16) * (self:getDistanceToPoint(targetX,targetY)/128)
			local perpAngle = angle + (math.pi/2)
			targetX = targetX + math.cos(perpAngle) * perpOff
			targetY = targetY + math.sin(perpAngle) * perpOff
		end
		angle = self:getAngleToPoint(targetX,targetY)
		targetX = user.x + math.cos(angle) * self.maxRange
		targetY = user.y + math.sin(angle) * self.maxRange
	else
		if user.dir == -1 then
			targetX = user.x - self.maxRange
		elseif user.dir == 1 then
			targetX = user.x + self.maxRange
		elseif user.dir == 0 then
			targetY = user.y - self.maxRange
		elseif user.dir == 2 then
			targetY = user.y + self.maxRange
		end
	end

	self.obstacles = {}
	-- lume.trace(user.x,user.y,targetX,targetY,directHit)
	Game.world:rayCast(user.x,user.y,targetX,targetY,self.wrapTargetClear)
	
	local penetration = self.penetration
	local lastX, lastY = targetX,targetY
	
	local forceX = math.cos(angle) * self.knockback
	local forceY = math.sin(angle) * self.knockback
	for i,v in ipairs(self.obstacles) do
		if v.obj.penetration then
			penetration = penetration - v.obj.penetration
		elseif Class.istype(v.obj,"ObjWall") then
			penetration = 0
		elseif Class.istype(v.obj,"ObjBase") then
			penetration = penetration - 10
		end
		if Class.istype(v.obj,"ObjBase") and v.obj:hasModule("ModActive") and
			(v.obj ~= targetObj or directHit) then
			-- self:setHit(v.obj, penetration,forceX,forceY)
		end
		if penetration <= 0 then
			lastX = v.x
			lastY = v.y
			break
		end
	end