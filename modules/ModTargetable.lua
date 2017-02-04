local ModTargetable = Class.create("ModTargetable",Entity)

function ModTargetable:create()
	self.targetPriority = self.targetPriority or 10
end

function ModTargetable:setTargetPriority( priority )
	self.targetPriority = priority
end
return ModTargetable