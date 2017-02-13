local ModMelee = Class.create("ModMelee",Entity)
ModMelee.dependencies = {"ModHitboxMaker"}
ModMelee.trackFunctions = {"onMeleeAttack"}
local Keymap  = require "xl.Keymap"
local FXSimple = require "objects.fx.FXSimple"

function ModMelee:setFrameData( startup, activeFrame, recovery)
	self.startUp = startup
	self.activeFrame = activeFrame or startup
	self.recovery = self.startUp + (recovery or 0)
	self.wrapCheckChar = lume.fn(ModMelee.mCheckChar, self)
	self.startingAttack = false
end

function ModMelee:setAttackAnimation( animation )
	if animation == "slash" then
		self.preAnim = "slash_p"
		self.recoveryAnim = "slash"
	else
	end
end

function ModMelee:setMeleeRange( range ,width)
	self.attackRange = range or 32
	self.attackWidth = width or 10
end
function ModMelee:setSelfCanMove( canMove )
	self.canMove = canMove
end

function ModMelee:onMelee(player, frame)
	self.timeSinceLastAttack = 0
	if self.canMove then
		player:normalMove()
		player:animate()
	end

	if frame == 1 and self.preAnim then
		player:changeAnimation(self.preAnim)
	end
	if frame >= self.startUp and self.recoveryAnim then
		player:changeAnimation(self.recoveryAnim)
	end
	if frame == self.activeFrame then
		self:onMeleeAttack(player)
	elseif frame >= self.recovery then
		player.exit = true
	end
end

function ModMelee:setHitboxInfo( hitboxInfo )
	self.hitboxInfo = hitboxInfo
end

function ModMelee:onMeleeAttack(player)
	self:createHitbox(self.hitboxInfo or {})
	local x = self.x
	if self.dir == -1 or self.dir == 1 then
		x = x + (15 * self.dir)
	end
	local fx2 = FXSimple(x,self.y,self)
	Game:add(fx2)
	fx2:setFadeSpeed(14)
	fx2:addSpritePiece(require("assets.spr.scripts.SprSlash"))
	fx2:setDir(self.dir)
	--fx2:setFollowTarget(self,0,0)
end

function ModMelee:onMeleeCheck( player, frame )
	if self.startingAttack then
		self:onMelee(player, frame)
		if player.exit == true then
			self.startingAttack = false
		end
	else
		local x,y = player.x, player.y
		local range = self.attackRange
		local wth = self.attackWidth
		self.numEnemies= 0
		-- lume.trace(player.dir)
		if player.dir == -1 then
			Game.world:queryBoundingBox(x-range,y-wth,x+wth,y+wth, self.wrapCheckChar)
		elseif player.dir == 1 then
			Game.world:queryBoundingBox(x-wth,y-wth,x+range,y+wth, self.wrapCheckChar)
		elseif player.dir == 0 then
			Game.world:queryBoundingBox(x-wth,y-range,x+wth,y+wth, self.wrapCheckChar)
		elseif player.dir == 2 then
			Game.world:queryBoundingBox(x-wth,y-wth,x+wth,y+range, self.wrapCheckChar)
		end
		if self.numEnemies > 0 then
			self.startingAttack = true
		end
		player:normalMove()
		player:animate()
		if not Keymap.isDown("use") then
			player.exit = true
		end
	end
end

function ModMelee:mCheckChar(fixture, x, y, xn, yn, fraction )
	local other = fixture:getBody():getUserData()
	local category = fixture:getCategory()
	if Class.istype(other,"ObjBase") and other:hasModule("ModActive") and other ~= self.user then --and (not other.faction or not self.faction or other.faction ~= self.faction) then
		self.numEnemies = self.numEnemies + 1
	end
	return 1
end

return ModMelee