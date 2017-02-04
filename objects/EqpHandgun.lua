local ObjBase = require "ObjBase"
local EqpHandgun = Class.create("EqpHandgun", ObjBase)
	
function EqpHandgun:create()
	self:addModule( require "modules.ModTargetEqp")
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
end

function EqpHandgun:useStand(player,frame)
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
end

return EqpHandgun