local FXReticle = require("objects.FXReticle")
local Keymap  = require "xl.Keymap"
local ModTargeter = Class.create("ModTargeter", Entity)

function ModTargeter:create()
	self.previousTargets = {}
end

function ModTargeter:setTarget( obj )
	if obj then
		-- lume.trace("slowing down", self.lockOnSlow)
		self.speedModX = self.speedModX + self.lockOnSlow
		self.speedModY = self.speedModY + self.lockOnSlow
		local target = FXReticle(self,obj,self.reticleSprite)
		Game:add(target)
		table.insert(self.previousTargets,obj)
	else
		self.previousTargets = {}
		-- lume.trace("speeding up",self.lockOnSlow)
		self.speedModX = self.speedModX - self.lockOnSlow
		self.speedModY = self.speedModY - self.lockOnSlow
	end
	self.targetObj = obj
end

function ModTargeter:orientTorwardsTarget()
	if self.targetObj and self.targetObj.destroyed then
		self:findNextTarget()
	end

	if self.targetObj and not self.targetObj.destroyed then
		local diffX = self.targetObj.x - self.x
		local diffY = self.targetObj.y - self.y
		if math.abs(diffX) > math.abs(diffY) then
			if diffX > 0 then
				self.dir = 1
			else
				self.dir = -1
			end
		else
			if diffY > 0 then
				self.dir = 2
			else
				self.dir = 0
			end
		end
		if not self:testProximity(self.targetObj.x,self.targetObj.y,self.viewDist * 1.2) then
			self:setTarget(nil)
		end
	else
		self:setTarget(nil)
	end
end

function ModTargeter:findNextTarget()
	-- self:setTarget(nil)
	local targets = Game:findObjectsWithModule("ModTargetable")
	local scorePriority 
	-- local scores = {}
	local minScore = 9999999
	local minObj = nil

	if (self.targetObj) then
		self.speedModX = self.speedModX - self.lockOnSlow
		self.speedModY = self.speedModY - self.lockOnSlow
	end

	for i,obj in ipairs(targets) do
		if self:validTarget(obj) then
			local dist = self:getDistanceToPoint(obj.x,obj.y)
			local modDir = self.dir
			if self:hasModule("ModControllable") then
				if Keymap.isDown("left") then
					modDir = -1
				elseif Keymap.isDown("right") then
					modDir = 1
				elseif Keymap.isDown("up") then
					modDir = 0
				elseif Keymap.isDown("down") then
					modDir = 2
				end
			end
			local angOffset = self:offsetFromView(obj,modDir)
			local score = dist* (math.max(math.pi/6,angOffset)) * (1/obj.targetPriority)
			if score < minScore then
				minScore = score
				minObj = obj
			end
		end
	end
	if minObj then
		self:setTarget(minObj)
	end
end

function ModTargeter:validTarget( obj )
	if obj ~= self and obj ~= self.targetObj and self:testProximity(obj.x,obj.y,self.viewDist) then
		return true
	end
	return false
end

return ModTargeter 