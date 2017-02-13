local ModHitboxMaker = Class.create("ModHitboxMaker", Entity)
local ObjAttackHitbox = require "objects.ObjAttackHitbox"
ModHitboxMaker.trackFunctions = {"onHitConfirm"}

function ModHitboxMaker:tick( dt )
	if self.toCreateHitbox then
		self:mCreateHitbox(unpack(self.toCreateHitbox))
		self.toCreateHitbox = nil 
	end
end
function ModHitboxMaker:createHitbox( ... )
	self.toCreateHitbox = {...}
end
function ModHitboxMaker:mCreateHitbox(wth, hgt, XOffset, YOffset, dmg, stn, pers, Xforce, Yforce, elem, deflect)
	local myWidth = wth
	local guardDamage
	local guardStun
	local unblockable
	local light
	local heavy, faction
	local dir = self.dir

	if type(wth) == "table" then
		myWidth = wth["width"] or 40
		hgt = wth["height"] or 40
		XOffset = wth["xOffset"] or 0
		YOffset = wth["yOffset"] or 0
		dmg = wth["damage"] or 10
		stn = wth["stun"] or 20
		pers = wth["persistence"] or 4
		Xforce = wth["xKnockBack"] or 0
		Yforce = wth["yKnockBack"] or 0
		elem = wth["element"] or "hit"
		deflect = wth["isDeflect"] or false
		guardDamage = wth["guardDamage"] or dmg
		guardStun = wth["guardStun"] or stn
		unblockable = wth["isUnblockable"] or false
		light = wth["isLight"] or false
		heavy = wth["heavy"] or false
		faction = wth["faction"] or self.faction

		if wth["radius"] then
			myWidth = wth["radius"]
			hgt = nil
		end
	end

	if (dir == -1 or dir == 1) then
		XOffset = XOffset * dir
		Xforce = Xforce * dir
	else
		if (dir == 0) then
			YOffset = -XOffset
		else
			YOffset = XOffset
		end
		XOffset = 0
		local tempWth = myWidth
		myWidth = hgt
		hgt = tempWth
		Yforce = Xforce * dir
		Xforce = 0
	end
	local x = self.x + XOffset
	local y = self.y + YOffset

	local ObjAttackHitbox = ObjAttackHitbox(x, y, myWidth, hgt, self, dmg, stn, pers, Xforce, Yforce, elem, deflect)
	ObjAttackHitbox:setGuardDamage(guardDamage)
	ObjAttackHitbox:setGuardStun(guardStun)
	ObjAttackHitbox:setIsUnblockable(unblockable)
	ObjAttackHitbox:setIsLight(light)
	ObjAttackHitbox:setFaction(faction)
	ObjAttackHitbox:setFollow(self, math.abs(XOffset),YOffset)
	ObjAttackHitbox:setHeavy(heavy)
	Game:add(ObjAttackHitbox)
	return ObjAttackHitbox
end

function ModHitboxMaker:onHitConfirm(target, hitType, hitbox) 
end

function ModHitboxMaker:addToAttackList( prob,conditionCheck,funct,properties)
	local newList = {}
	newList.weight = prob
	newList.condition = conditionCheck
	newList.funct = funct
	newList.properties = {}
	if properties then
		for i,v in ipairs(properties) do
			newList.properties[v] = true
		end
	end
	table.insert(self.attackList,newList)
end

return ModHitboxMaker