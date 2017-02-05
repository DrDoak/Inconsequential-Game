local ObjBaseUnit = require "objects.ObjBaseUnit"
local ObjEnemy = Class.create("ObjEnemy", ObjBaseUnit)

function ObjEnemy:init( )
	-- init other data
	self.max_health = 100
	self.health = 100

	--initialize movement data
	self.maxJumpTime = 300
	self.currentJumpTime = 0
	self.jumpSpeed = 490
	self.maxAirJumps = 1
	self.deceleration = -9
	self.maxSpeed = 4 * 32
	self.acceleration = 20 * 32
	self.x = 0
	self.y = 0
	self.faction = "enemy"
end

function ObjEnemy:create()
	ObjBaseUnit.create(self)

	self:addModule(require "modules.ModProjectileEnemy")
	self:setAttackRangeRate(80,1)
	
	-- self:setMeleeHitbox({width = 60, height = 15,xOffset = 10, yOffset = -5, damage = 15, guardDamage = 12,
	-- stun = 35, persistence = 0.15,xKnockBack = 4 * 32, yKnockBack = -3 * 32, element = "fire"})
	-- self:setFrameData(8,10,10)
	-- self:setAttackAnimation("slash")


	self:addSpritePiece(require("assets.spr.scripts.SprLegBoots"))
	self:addSpritePiece(require("assets.spr.scripts.SprBodyUniform"))
	self:addSpritePiece(require("assets.spr.scripts.SprHeadGeneric"))
	self:addSpritePiece(require("assets.spr.scripts.SprHatHelmet"))

	self:createBody( "dynamic" ,true, true)
	self.shape = love.physics.newRectangleShape(7, 16)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6)

	self.fixture:setCategory(CL_NPC)
	self:setEquipCreateItem("EqpHandgun")
end

return ObjEnemy
