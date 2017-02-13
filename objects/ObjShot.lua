local ObjBase = require "ObjBase"
local ObjShot = Class.create("ObjShot", ObjBase)

function ObjShot:init( x,y,attacker )
	self.x = x
	self.y = y
	self.attacker = attacker
end

function ObjShot:create()
	self:addModule( require "modules.ModProjectile")
	self:setFaction(self.attacker.faction)

	self:createBody("dynamic", true, true)
	-- self:setNoGrav(true)

	self.shape = love.physics.newRectangleShape(16,16)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6, true)
	
	self:addSpritePiece(require(self.image or "assets.spr.scripts.SprShot"))
	
	--Sprite initialization
	self.refresh = 30 
	self.damage = self.damage or 20
	self.stun = self.stun or 0.1
	self.range = self.range or 120
	self.forceX = self.forceX or 12 * 32
	self.forceY = self.forceY or -6 * 32
	self.element = self.element or "hit"

	if self.attacker.dir == 1 then
		self:fireAtPoint(self.x + (self.firePointX or 128),self.y +(self.firePointY or 0),self.speed or 4*32)
	else
		self:fireAtPoint(self.x - (self.firePointX or 128),self.y + (self.firePointY or 0),self.speed or 4*32)
	end

	self.fixture:setSensor(true)
	self:orientAllSprites()
end

return ObjShot