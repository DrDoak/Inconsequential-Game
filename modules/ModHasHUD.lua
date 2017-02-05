local ModHasHUD = Class.create("ModHasHUD", Entity)
local Healthbar = require "mixin.Healthbar"
local EquipIcon = require "mixin.EquipIcon"
local TextInterface = require "mixin.TextInterface"

function ModHasHUD:create()
	if not (self.healthbar and self.guardbar and self.equipIcons) then
		-- healthbar
		self.healthbar = Healthbar( self.max_health )
		self.healthbar.fgcolor = { 150, 0, 0 }
		self.healthbar.redcolor = { 255, 0, 0 }
		self.healthbar:setPosition( 72, 5 )
		self.healthbar.bgcolor = {100,100,100}
		--self.healthbar:setImage(love.graphics.newImage( "assets/HUD/interface/marble.png" ))

		-- guardbar
		self.guardbar = Healthbar( self.max_health )
		self.guardbar.fgcolor = { 40, 200, 40 }
		self.guardbar:setPosition( 72, 20 )
		self.guardbar:setImage(love.graphics.newImage( "assets/HUD/interface/gold.png" ))
		--Primary Equip Icon
		self.equipIcons = {}
		self.equipIcons["up"] = EquipIcon(nil)
		self.equipIcons["up"]:setPosition(2,74)
		self.equipIcons["neutral"] = EquipIcon(nil)
		self.equipIcons["neutral"]: setPosition(2,146)
		self.equipIcons["down"] = EquipIcon(nil)
		self.equipIcons["down"]:setPosition(2,218)

		for k,v in pairs(self.currentEquips) do
			if self.equipIcons[k] then
				self.equipIcons[k]:setImage(v.invSprite)
			end
		end
		self.TextInterface = TextInterface()
	end
	Game.hud:insert( self.healthbar )
	Game.hud:insert( self.guardbar  )
	Game.hud:insert( self.TextInterface )
	for k,v in pairs(self.equipIcons) do
		Game.hud:insert( v )
	end
end

function ModHasHUD:setHealth( health ,redHealth)
	health = math.min( health, self.max_health )
	self.healthbar.redValue = redHealth or health
	self.healthbar.value = health
	--ObjBaseUnit.setHealth(self,health)
end

function ModHasHUD:setGuard( guard )
	guard = math.min( guard, self.max_shield )
	guard = math.max(guard, 0)
	self.shield = guard
	self.guardbar.value = guard
end


return ModHasHUD