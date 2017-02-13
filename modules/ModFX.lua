local ModFX = Class.create("ModFX", Entity)

function ModFX:setTimer( timer )
	self.timer = timer
end

function ModFX:tick( dt )
	if self.timer then
		self.timer = self.timer - dt
		if self.timer <= 0 then
			Game:del(self)
		end
	end
	if not self.followObj or self.followObj.destroyed then
		self.x = self.x + (self.xSpeed or 0)
		self.y = self.y + (self.ySpeed or 0)
	end

	if self.sprite and self.endIndex then
		if self.sprite:getIndex() >= self.endIndex then
			if self.keepAtEnd then
				self.sprite:setAnimation(self.endIndex,1,1)
			else
				Game:del(self)
			end
		end
	elseif self.hudSprite and self.endIndex then
		if self.hudSprite:getIndex() >= self.endIndex then
			if self.keepAtEnd then
				self.sprite:setAnimation(self.endIndex,1,1)
			else
				Game:del(self)
			end
		end
	end
	local offset = self.xOffset
	
	if self.fadeSpeed then
		self.alpha = self.alpha - self.fadeSpeed
		if self.alpha <= 0 then
			Game:del(self)
		end
	end
	self:changeAnimation("main")
	self:setSprColor(self.red,self.green,self.blue,(self.alpha or 255))
	self.angle = (self.angle or 0) + (self.rotSpeed or 0)
end

function ModFX:setDir( dir )
	self.dir = dir
end

function ModFX:setColor( red, green, blue, alpha )
	self.red = red or 255
	self.blue = blue or 255
	self.green = green or 255
	self.alpha = alpha or self.alpha
end

function ModFX:setAngle( angle )
	self.angle = angle
end

function ModFX:setRotSpeed( rotSpeed )
	self.rotSpeed = rotSpeed
end

function ModFX:setDir(dir)
	self.dir = dir
end

function ModFX:setTimer( timer )
	self.timer = timer
end

function ModFX:setFadeSpeed( fadeSpeed )
	self.alpha = 255
	self.fadeSpeed = (fadeSpeed or 0)
end

function ModFX:setSpeed( xSpeed, ySpeed )
	self.xSpeed = xSpeed or 0
	self.ySpeed = ySpeed or 0
end

function ModFX:setKeepAtEnd( keepAtEnd )
	self.keepAtEnd = keepAtEnd
end

function ModFX:setSize( width, height )
	self.sprite:setSize(width,height)
end

function ModFX:setPosition( x,y )
	self.x = x
	self.y = y
	self.sprite:setPosition(self.x,self.y)
end

return ModFX