local ModCharacterDetector = Class.create("ModCharacterDetector",Entity)

function ModCharacterDetector:create()
	self.wrapCheckChar = lume.fn(ModCharacterDetector.mCheckChar, self)
	self.loSObjs = {}
	self.characterTrackInfo = {}
	-- self.viewDist = 80
	self.wrapClearView = lume.fn(ModCharacterDetector.mClearView,self)
	self.viewCone = math.pi/2
	-- lume.trace(self.type)
end

function ModCharacterDetector:tick( dt )
	local characters = Game:findObjectsWithModule("ModCharacter")
	for i,char in ipairs(characters) do
		if not self.loSObjs[char.name] then
			if self:canSeeObj(char) then
				self:addInZone(char)
			end
		end 
	end
	for k,v in pairs(self.loSObjs) do
		self.characterTrackInfo[v.name].timeInView = self.characterTrackInfo[v.name].timeInView + dt
		self:trackCharacter(v)
		self:outOfZone(v)
	end
end

function ModCharacterDetector:canSeeObj( obj )
	if obj ~= self and self:angleMatch({x=obj.x,y=obj.y}) and self:testProximity(obj.x,obj.y,self.viewDist) then
		self.clearView = true
		self.otherObj = obj
		Game.world:rayCast(self.x,self.y,obj.x,obj.y,self.wrapClearView)
		return self.clearView
	else
		return false
	end
end

function ModCharacterDetector:angleMatch(pos)
	local angleOff = self:offsetFromView(pos)
	--lume.trace(self.type, angle,math.abs(angle - curAngle),self.viewCone)
	if angleOff < self.viewCone then
		return true
	else
		return false
	end
end

function ModCharacterDetector:offsetFromView( pos ,dir)
	local angle = self:getAngleToPoint(pos.x,pos.y)
	local curAngle = 0
	local dir = dir or self.dir
	if dir == 0 then
		curAngle = (3*math.pi)/2
	elseif dir == 2 then
		curAngle = math.pi/2 
	elseif dir == -1 then
		curAngle = math.pi
	end
	return math.min( math.abs(angle - curAngle),math.abs((angle + (math.pi*2)) - curAngle) )
end

function ModCharacterDetector:mClearView(fixture, x, y, xn, yn, fraction )
	if fixture then
		local other = fixture:getBody():getUserData()
		local category = fixture:getCategory()
		if Class.istype(other,"ObjBase") and not fixture:isSensor() and other ~= self and other ~= self.otherObj and (not other.Vheight or other.Vheight < 32) then
			self.clearView = false
			return 0
		end
	end
	return 1
end


function ModCharacterDetector:trackCharacter( character )
	local ch = self.characterTrackInfo[character.name]
	if character.health ~= ch.health and character.lastHitObj then
		local diff = character.health - ch.health
		ch.health = character.health
	end
	if character.currentEquip ~= ch.currentEquip then
		ch.currentEquip = character.currentEquip
	end
	-- body self:emitEvent(character)
end

function ModCharacterDetector:addInZone(other)
	-- lume.trace("Added Character: ", other.name, self.name)
	self.characterTrackInfo[other.name] = {}
	self.characterTrackInfo[other.name].health = other.health
	self.characterTrackInfo[other.name].currentEquip = other.currentEquip
	self.characterTrackInfo[other.name].timeInView = 0
	self.loSObjs[other.name] = other
end

function ModCharacterDetector:removeInZone( other )
	-- lume.trace("Removed Character: ", other.name, self.name,self.characterTrackInfo[other.name].timeInView)
	self.characterTrackInfo[other.name] = nil
	self.loSObjs[other.name] = nil
end

function ModCharacterDetector:mCheckChar(fixture, x, y, xn, yn, fraction )
	if fixture then
		local other = fixture:getBody():getUserData()
		local category = fixture:getCategory()
		if other ~= nil and Class.istype(other,"ObjBase") and other:hasModule("ModCharacter") and other ~= self  then
			if not self.loSObjs[other.name] then
				self:addInZone(other)
			end
		end
	end
	return 1
end

function ModCharacterDetector:outOfZone( object )
	-- lume.trace("out of zone")
	if object.destroyed or not self:canSeeObj(object) then
		self:removeInZone(object)
	end
	-- local x, y = object.body:getPosition()
	-- if x < self.x - self.sightRange or x > (self.x + self.sightRange) or y < self.y + self.sightRange or y > (self.y + self.sightRange) then
	-- 	-- self:emitEvent(object)
	-- 	util.deleteFromTable(self.loSObjs,object)
	-- end
end

return ModCharacterDetector