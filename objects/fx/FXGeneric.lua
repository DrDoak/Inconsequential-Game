local FXGeneric = Class.create("FXGeneric", Entity)
FXGeneric.dependencies = {"ModDrawable"}
local Lights = require "xl.Lights"
FXGeneric.__package = "fx"

-- make FXGeneric transient
util.transient( FXGeneric )

function FXGeneric:init(posX , posY, creator, timer)
	self.x = posX
	self.y = posY
	self.creator = creator
	self.timer = timer
end

function FXGeneric:setImage( image,width,height,frames ,fps)
	if self.inserted then
		Game.scene:remove(self.sprite)
		self.inserted = false
	end
	self.sprite = xl.Sprite(image, width,height)
	self.sprite:setSize(width,height)
	self.sprite:setOrigin(width/2,height/2) 
	self.sprite:setPosition(self.x,self.y)
	self.sprite:setAnimation(frames,1,fps)
	self:setColor(self.red,self.green,self.blue,self.alpha)
end

function FXGeneric:setOrigin( x,y )
	self.sprite:setOrigin(x,y) 
end
function FXGeneric:create()
end

function FXGeneric:tick(dt)
	if self.timer then
		self.timer = self.timer - dt
		if self.timer <= 0 then
			Game:del(self)
		end
	end
	if self.followObj and not self.followObj.destroyed then
		self.x = self.followObj.x 
		self.y = self.followObj.y 
	else
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
	if self.dir == 1 or self.dir == -1 then
		self.sprite:setScale(self.dir,1)
	else
		self.sprite:setScale(1,1)
	end
	self.sprite:setScale(1,1)
	offset = -(self.xOffset or 0)
	self.sprite:setAngle(self.angle or 0)
	self.sprite:setPosition(self.x + (offset or 0), self.y + 16 + (self.yOffset or 0))
	if self.fadeSpeed then
		self.alpha = self.alpha - self.fadeSpeed
		if self.alpha <= 0 then
			Game:del(self)
		end
	end
	self.sprite:setColor(self.red,self.green,self.blue,(self.alpha or 255))
	self.angle = (self.angle or 0) + (self.rotSpeed or 0)
	self.sprite:setAngle(self.angle)
	self:updateLightPosition(self.x,self.y)
	if self.sprite and not self.inserted then
		Game.scene:insert(self.sprite)

		if self.depth then
			Game.scene:move(self.sprite, (self.depth or self.y))
		end
		--Game.scene:move(self.sprite, (self.depth or self.y))
		self.inserted = true
	end
end

function FXGeneric:destroy()
	if self.inserted and self.sprite then
		Game.scene:remove(self.sprite)
	end
	if self.lights then
		for key, value in pairs(self.lights) do
			self:delLight(key)
		end
	end
end

function FXGeneric:setColor( red, green, blue, alpha )
	self.red = red or 255
	self.blue = blue or 255
	self.green = green or 255
	self.alpha = alpha or self.alpha
end

function FXGeneric:setAngle( angle )
	self.angle = angle
end

function FXGeneric:setRotSpeed( rotSpeed )
	self.rotSpeed = rotSpeed
end
function FXGeneric:setDir(dir)
	self.dir = dir
end

function FXGeneric:setOffset( xOffset, yOffset )
	self.xOffset = xOffset
	self.yOffset = yOffset
end

function FXGeneric:setDepth( depth )
	self.depth = depth
end

function FXGeneric:setTimer( timer )
	self.timer = timer
end

function FXGeneric:setFadeSpeed( fadeSpeed )
	self.alpha = 255
	self.fadeSpeed = (fadeSpeed or 0)
end

function FXGeneric:setSpeed( xSpeed, ySpeed )
	self.xSpeed = xSpeed or 0
	self.ySpeed = ySpeed or 0
end

function FXGeneric:setAnimation( xFrames,yFrames,framerate,stopAtFrame )

	if stopAtFrame then
		self.endIndex = stopAtFrame - 1
	end
	self.endIndex = stopAtFrame - 1
	self.sprite:setAnimation(xFrames,yFrames,framerate)
end

function FXGeneric:setKeepAtEnd( keepAtEnd )
	self.keepAtEnd = keepAtEnd
end

function FXGeneric:setSize( width, height )
	self.sprite:setSize(width,height)
end

function FXGeneric:setPosition( x,y )
	self.x = x
	self.y = y
	self.sprite:setPosition(self.x,self.y)
end

function FXGeneric:addLight( lightName, x,y,radius, r,g,b)
	if not self.lights then self.lights = {} end
	local lights = Lights.newAreaLight((radius or 32))
	lights:setPosition(self.x, self.y)
	lights:setColor((r or 1),(g or 1),(b or 1))
	Game.lights:add(lights)
	local table = {
	light = lights,
	offsetX = x,
	offsetY = y
	}
	self.lights[lightName] = table
end

function FXGeneric:delLight( lightName )
	if self.lights[lightName] then
		Game.lights:del(self.lights[lightName].light)
		self.lights[lightName] = nil
	end
end

function FXGeneric:updateLightPosition( x , y )
	if self.lights then
		for key, piece in pairs( self.lights ) do
			self.lights[key].light:setPosition(x + self.lights[key].offsetX,y + self.lights[key].offsetY)
		end
	end
end

function FXGeneric:setFollowObj( follow )
	self.followObj = follow
end
return FXGeneric