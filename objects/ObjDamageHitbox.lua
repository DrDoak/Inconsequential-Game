local ObjAttackHitbox = require "objects.ObjAttackHitbox"
local ObjDamageHitbox = Class.create("ObjDamageHitbox", ObjAttackHitbox)
util.transient(ObjDamageHitbox)

function ObjDamageHitbox:init(creator, damage, stun, 
	refresh, forceX, forceY, element, ignoreType)
	self.attacker = creator
	self.damage = damage
	self.stun = stun
	self.refreshTime = refresh
	self.forceX = forceX
	self.forceY = forceY
	self.element = element
	self.ignoreType = ignoreType or ""
end

function ObjDamageHitbox:create()
	self.body = love.physics.newBody(self:world(),0,0, "kinematic")
	self.body:setFixedRotation(true)
	self.body:setUserData(self)
	self.shape = self.attacker.shape
	self.faction = self.faction or self.attacker.faction
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self.fixture:setSensor(true)
	self.refreshTime = self.refreshTime or 30
	-- Log.debug(self.attacker.type)
	-- self.created = true
	self.objectsHit = {}
	self.active = true
	self.refresh = 0
	-- self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
	-- ObjAttackHitbox.create(self)
end

function ObjDamageHitbox:tick(dt)
	self.x, self.y = self.body:getPosition()
	if self.attacker and not self.attacker.destroyed then
		self.forceX = self.forceX * self.attacker.dir
		local posX, posY = self.attacker.body:getPosition()
		self:setPosition(posX,posY)
		self:setAngle(self.attacker.body:getAngle())

		if Class.istype(self.attacker,"ObjUnit") then
			if self.attacker.state == 3 then
				self.active = false
			else
				self.active = true
			end
		end
		ObjAttackHitbox.tick(self,dt)
	else
		Game:del(self)
	end
end

function ObjDamageHitbox:setActive( active )
	self.active = active
end

function ObjDamageHitbox:onCollide(other, collision)
	if other ~= nil and other ~= self.attacker and self.active == true and not Class.istype(other, self.ignoreType) then
		return ObjAttackHitbox.onCollide(self,other,collision)
	end
	return false
end

return ObjDamageHitbox