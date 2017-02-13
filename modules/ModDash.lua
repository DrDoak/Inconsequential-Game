local ModDash = Class.create("ModDash", Entity)
local Keymap = require "xl.Keymap"

function ModDash:create()
	self.clip = false
	self.redHealthDelay = 0
	self.redHealth = self.health
end


function ModDash:normalState( dt )
	self:controlDash()
	if self.redHealthDelay > 0 then
		self.redHealthDelay = self.redHealthDelay - dt
	elseif self.redHealth < self.health then
		self.redHealth = math.min(self.health,self.redHealth + 1)
		self:setHealth(self.health,self.redHealth)
	end
end

function ModDash:controlDash() 
	if Keymap.isDown("dash") and self.redHealth > 0 then
		if self.state == 3 then
			self.state = 1
			self.stun = 0
			return
		end
		self.redHealth = math.max(0, self.redHealth - 20)
		self:setHealth(self.health,self.redHealth)
		self.redHealthDelay = 120

		self.invincibleTime = 15
		self.dashVel = {}
		local dashDir = self.dir
		if Keymap.isDown("left") then
			dashDir = -1
		end
		if Keymap.isDown("right") then
			dashDir = 1
		end
		if Keymap.isDown("up") then
			dashDir = 0
		end
		if Keymap.isDown("down") then
			dashDir = 2
		end 
		if dashDir == -1 or dashDir == 1 then
			self.dashVel.x = (12 * 32 * dashDir)
			self.dashVel.y = 0
		elseif dashDir == 0 then
			self.dashVel.x = 0
			self.dashVel.y = -12 * 32
		elseif dashDir == 2 then
			self.dashVel.x = 0
			self.dashVel.y = 12 * 32
		end

		local function dash(player,frame)
			self.status = "dashing"
			self.fixture:setMask(CL_NPC)
			if frame < 14 then
				self:setSprColor(0,0,255,100)
				player.body:setLinearVelocity(self.dashVel.x,self.dashVel.y) --player.velY)
			elseif frame < 16 then
				self:setSprColor(255,255,255,255)
				--player.body:setLinearVelocity(( 16 - frame) * 32 * player.dir, 0)--player.velY)
			else
			end
			--player.dir = - player.dir
			player:changeAnimation({"dash","slideMore"})
			--player.dir = - player.dir
			if frame > 30 then
				self.fixture:setMask(16)
				player.exit = true
			end
		end
		self:setSpecialState(dash)
	end
end

return ModDash