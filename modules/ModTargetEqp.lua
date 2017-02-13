local ModTargetEqp = Class.create("ModTargetEqp",Entity)
local FXShot = require("objects.FXShot")
ModTargetEqp.dependencies = {"ModEquippable","ModShooter"}
local Scene = require "xl.Scene"

ModTargetEqp.trackFunctions = {"fireWeapon"}
function ModTargetEqp:create()
	-- States
	self.stability = 0.5
	self.marksmanship = 0.5
	self.aimSpeed = 0.01
	self.focusAim = 0.03
	self.aimAcquisition = 0.3
	self.quickDraw = 0.5
	self.critAimSpeed = self.aimSpeed * 0.6
	self.reactionSpeed = 0.7
	self.maxRange = 640
	self.penetration = 1.0
	self.recoil = 0.4
	self.knockback = 2 * 32 
	self.stun = 20
	self.damage = self.damage or 35


	-- measurement values
	self.critChance = 0.0

	self.currentRecoil = 0

	self.penaltyMovement = 0
	self.penaltyTarget = 0
	self.penaltyAim = 0
	self.penaltyReaction = 0

	self.critPenaltyMovement = 0
	self.critPenaltyTarget = 0
	self.critPenaltyAim = 0
	self.critPenaltyReaction = 0

	self.aimTime = 0
	self.lastTarget = nil
	self.lastVel = {x=0,y=0}
	self.lastTargetVel = {x=0,y=0}


	local drawFunc = function()
		local floor = math.floor
		local bx,by = self.targetX,self.targetY
		local loveGraphics = love.graphics
		loveGraphics.push()
		loveGraphics.translate( bx, by + 16 )
		-- loveGraphics.setColor(50, 200, 50)

		love.graphics.setFont( xl.getFont() )
		love.graphics.setPointSize(8)

		love.graphics.print("Crit:".. math.floor(self.critChance * 100) .. "%", 0, 0)

		loveGraphics.pop()
    end
	self.infoText = Scene.wrapNode({draw = drawFunc}, 9900)
	self.wrapTargetClear = lume.fn(ModTargetEqp.mTargetClear, self)

end

function ModTargetEqp:destroy( dt )
	if self.infoText and self.insertedTargetText then
		Game.scene:remove(self.infoText)
	end
end

function ModTargetEqp:onEquipTick( dt )
	if self.user.targetObj then
		self:calculateAccuracy(self.user,self.user.targetObj,dt)
		self.targetX = self.user.targetObj.x - 48
		self.targetY = self.user.targetObj.y - 88
		if not self.insertedTargetText then
			Game.scene:insert(self.infoText)
			self.insertedTargetText = true
		end
	elseif self.insertedTargetText then
		self.lastTarget = nil
		Game.scene:remove(self.infoText)
		self.insertedTargetText = false
	end
end

function ModTargetEqp:calculateAccuracy( user, target ,dt)
	local dist = xl.distance(user.x,user.y,target.x,target.y)
	local aimImprovement = 0
	-- Aiming penalty
	if self.lastTarget ~= target then
		self.aimTime = 0
		self.lastTarget = target
		self.critChance = 0
	end
	aimImprovement = self.aimSpeed
	
	if target.untargetable then
 		self.critChance = 0
 	end
	--math.max(0, self.penaltyAim - (self.aimSpeed * ( self.penaltyAim/0.2 ) * (80/math.max(16,dist)) + 0.01)* dt )

	-- Movement penalty
	local newVelX = user.velX - user.referenceVelX
	local newVelY = (user.velY - user.referenceVelY) * 1.4

	if 	(math.abs(newVelX) > 16 and math.abs(self.lastVel.x) < 16) or
		(math.abs(newVelY) > 16 and math.abs(self.lastVel.y) < 16) or 
		(math.abs(newVelX) > 16 and (util.sign(newVelX) ~= util.sign(self.lastVel.x))) or 
		(math.abs(newVelY) > 16 and (util.sign(newVelY) ~= util.sign(self.lastVel.y))) then
		--self.penaltyMovement = math.min(0.5, self.penaltyMovement + 0.2)
		aimImprovement = -0.2--aimImprovement * self.stability * 0.3
	else
		--self.penaltyMovement = math.max(0, self.penaltyMovement - (self.stability * (self.penaltyMovement/0.5) + 0.03) * (48/math.max(16,dist)) * dt)
	end
	
	if math.abs(user.velX) > 32 or math.abs(user.velY) > 32 then
		self.aimTime = 0
	else
		self.aimTime = self.aimTime + dt
	end

	if self.aimTime > self.aimAcquisition then
		aimImprovement = aimImprovement + self.focusAim
	else
		aimImprovement = aimImprovement * self.stability 
	end

	self.lastVel.x = newVelX
	self.lastVel.y = newVelY
	-- -- target Movement penalty
	-- local relVelX = target.velX - target.referenceVelX
	-- local relVelY = (target.velY - target.referenceVelY) * 1.4
	-- if 	(math.abs(relVelX) > 16 and math.abs(self.lastTargetVel.x) < 16) or
	-- 	(math.abs(relVelY) > 16 and math.abs(self.lastTargetVel.y) < 16) or 
	-- 	(math.abs(relVelX) > 16 and (util.sign(relVelX) ~= util.sign(self.lastTargetVel.x))) or 
	-- 	(math.abs(relVelY) > 16 and (util.sign(relVelY) ~= util.sign(self.lastTargetVel.y))) then
	-- 	self.penaltyTarget = math.min(0.8, self.penaltyTarget + 0.2)
	-- else
	-- 	self.penaltyTarget = math.max(0, self.penaltyTarget - (self.marksmanship * (self.penaltyTarget/0.5) * (64/math.max(16,dist) + (0.01) )) * dt)
	-- end
	-- self.lastTargetVel.x = relVelX
	-- self.lastTargetVel.y = relVelY

	-- self.penaltyMovement = math.max(0, math.min())
	-- self.critPenaltyMovement = math.max(0,math.min())

	self.critChance = math.min(1.0, self.critChance + aimImprovement)
end

function ModTargetEqp:mTargetClear(fixture, x, y, xn, yn, fraction )
	if fixture then
		local other = fixture:getBody():getUserData()
		local category = fixture:getCategory()
		-- lume.trace(other.type)
		if other ~= nil and not fixture:isSensor() and other ~= self  then
			local dist =  xl.distance(self.user.x,self.user.y,x,y)
			local added = false
			for i,v in ipairs(self.obstacles) do
				if other == v.obj then
					added = true
					break
				end
				if dist < v.dist then
					local newObj = {}
					newObj.dist = dist
					newObj.obj = other
					newObj.x = x
					newObj.y = y
					lume.trace()
					table.insert(self.obstacles,newObj)
					added = true
					break
				end
			end
			if not added then
				local newObj = {}
				newObj.dist = dist
				newObj.obj = other
				newObj.x = x
				newObj.y = y
				table.insert(self.obstacles,newObj)
			end
		end
	end
	return 1
end

function ModTargetEqp:meleeAttack()
	lume.trace()
end

function ModTargetEqp:fireWeapon()
	if not self.user.targetObj then
		self:meleeAttack()
		return 
	end
	self.currentRecoil = self.recoil

	local user = self.user
	local targetX = user.x
	local targetY = user.y
	local targetObj = user.targetObj
	local directHit = true
	local angle = 0

	self:onAttack(targetObj.x,targetObj.y,-(self.height + 24))
	if math.random() < self.critChance then
		self:onCrit(targetObj.x,targetObj.y,-(self.height + 24),targetObj)
	end
end

function ModTargetEqp:onCrit( targetX,targetY,height,targetObj )
	-- body
end

-- function ModTargetEqp:setHit(obj,penetration,forceX,forceY)
-- 	obj:setHitState({stun = self.stun,forceX=forceX,forceY=forceY,damage=self.damage,
-- 		element=self.element,unblockable=self.unblockable,
-- 		shieldDamage=self.shieldDamage, blockStun=self.blockStun,attacker=self.user})
-- end

return ModTargetEqp