local ModShield = Class.create("ModShield", Entity)
local FXGeneric = require "objects.fx.FXGeneric"

function ModShield:create()
	self.rechargeShieldDelay = 0
	self:setMaxShield(100)
	self.shield = self.max_shield
	self:setSRechargeRate(20)

	self:addEmitter("shieldFX" , "assets/spr/fx/shard.png",16,nil,4,-32)
	self:setRandomDirection("shieldFX" , 2 * 32)
	self:setRandRotation("shieldFX",2,0,1)
	local shieldFX = self.psystems["shieldFX"]
	shieldFX:setParticleLifetime(1, 2);
	self:setFade("shieldFX")
end

function ModShield:tick( dt )
	if self.rechargeShieldDelay > 0 then
		self.rechargeShieldDelay = self.rechargeShieldDelay - dt
	elseif (self.shield < self.max_shield) then
		self:setGuard(self.shield + (self.shieldRechargeRate * dt))
	end
	if self.shield > 0 and self.status == "normal" and not self.targetObj then
		self.blocking = true
	else
		self.blocking = false
	end
end

function ModShield:setMaxShield( max_shield )
	self.max_shield = max_shield
end

function ModShield:setSRechargeRate( rechargeRate )
	self.shieldRechargeRate = rechargeRate
end

function ModShield:onBlock( hitInfo )
	-- self.shield = math.max(0,self.shield - (shieldDamage or damage))
	local sDmg = (hitInfo.shieldDamage or hitInfo.damage)
	self:setGuard(self.shield - sDmg)
	-- local fx = FXGeneric(self.x,self.y,self,40)
	-- fx:setImage("assets/spr/fx/shards.png",32,18,"1-6",0)
	-- fx:setAngle(math.random(0,math.pi*2))
	-- fx:setSpeed(forceX/60 + math.random(-0.5,0.5),forceY/60 + math.random(-0.5,0.5))
	local red = 255 * (self.max_shield - self.shield)/self.max_shield
	local green = math.max(0,(self.shield/self.max_shield) * 255 - (self.max_shield - self.shield))
	-- fx:setColor(red,green,0,100)
	-- Game:add(fx)
	self:setColors( "shieldFX", {red,green,0,100,red,green,0,0})
	self:emit("shieldFX", math.min(math.max(math.floor(sDmg/5),2),8))

	local x = self.x
	if self.dir == -1 or self.dir == 1 then
		x = x + (4 * self.dir)
	end
	local fx2 = FXGeneric(x,self.y - 32,self,0.25)
	fx2:setImage("assets/spr/fx/block_side.png",64,128,"1-8",30)
	fx2:setDir(self.dir)
	fx2:setDepth(9000)
	fx2:setSize(24,48)
	fx2:setColor(red,green,0,150)
	Game:add(fx2)

	self.rechargeShieldDelay = 2
	local forceX = hitInfo.forceX
	local forceY = hitInfo.forceY
	if not self.superArmor then
		self.body:setLinearVelocity(forceX * self.KBRatio * 0.75,forceY * self.KBRatio * 0.75)
	end


	if self.shield <= 0 and self.maxShield ~= 0 then
		self.stun = 3.0
		self.rechargeShieldDelay = 4
		self:emit("shieldFX", 8)
		-- for i=1,6 do
		-- 	local fx2 = FXGeneric(self.x,self.y,self,40)
		-- 	fx2:setImage("assets/spr/fx/shards.png",32,18,"1-6",0)
		-- 	fx2:setAngle(math.random(0,math.pi*2))
		-- 	fx2:setSpeed(math.random(-1,1),math.random(-1,1))
		-- 	fx2:setColor(255,255,0,200)
		-- 	Game:add(fx2)
		-- end
		self.invincibleTime = 0
		self.status = "guard_broken"
		self.state = 3
	end
end

return ModShield