local ObjBase = require "ObjBase"
local EqpHandgun = Class.create("EqpHandgun", ObjBase)
	
function EqpHandgun:create()
	self:addModule( require "modules.ModTargetEqp")
	self:addModule( require "modules.ModMelee")
	--self:addModule( require "modules.ModHitboxMaker")
	self:addModule(require "modules.ModDrawable")

	self.shape = love.physics.newRectangleShape(32,32)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22)

	self:addSprite(require("assets.spr.scripts.SprHandgun"))

	self.isKeyItem = false
	self.isPrimary = true
	self.lockOnAnim = "aim_handgun"
	self.name = "Handgun" --String that displays in Inventory
	self.invSprite = love.graphics.newImage( "assets/spr/eqp/icon_handgun.png" )

	self.fireRate = 20
	self.damage = 10
	self.fireAnim = "fire_handgun"
	self.spritePiece = 	self:createSpritePiece(16,16,"weapon", require ("assets.spr.scripts.SprHandgun"))
	--self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
	self:setFrameData(4,10,10)
	self:setAttackAnimation("slash")
	self:setSelfCanMove(true)
	self:setMeleeRange(32,13)
	local wth = {}
	wth["width"] = 40
	wth["height"] = 32
	wth["xOffset"] = 14
	wth["persistence"] = 0.15
	wth["damage"] = 30
	wth["xKnockBack"] = 6 * 32
	wth["stun"] = 0.25
	self:setHitboxInfo(wth)
		-- myWidth = wth["width"] or 40
		-- hgt = wth["height"] or 40
		-- XOffset = wth["xOffset"] or 0
		-- YOffset = wth["yOffset"] or 0
		-- dmg = wth["damage"] or 10
		-- stn = wth["stun"] or 20
		-- pers = wth["persistence"] or 4
		-- Xforce = wth["xKnockBack"] or 0
		-- Yforce = wth["yKnockBack"] or 0
		-- elem = wth["element"] or "hit"
		-- deflect = wth["isDeflect"] or false
		-- guardDamage = wth["guardDamage"] or dmg
		-- guardStun = wth["guardStun"] or stn
		-- unblockable = wth["isUnblockable"] or false
		-- light = wth["isLight"] or false
		-- heavy = wth["heavy"] or false
		-- faction = wth["faction"] or self.faction
end

function EqpHandgun:useStand(player,frame)
	if player.targetObj then
		player:normalMove()
		player:animate()
		if frame == 1 then
			self:fireWeapon()
		elseif frame <= 10 then
			player:changeAnimation(self.fireAnim)
		elseif frame < self.fireRate then
			player:changeAnimation(self.lockOnAnim)
		else
			player.exit = true
		end
	else
		self:onMeleeCheck(player, frame)
	end
end

return EqpHandgun