local ModLineFX = Class.create("ModLineFX", Entity)
local Scene = require "xl.Scene"

ModLineFX.dependencies = {"ModDrawable"}

function ModLineFX:create()
	self.currentAngle = 0
	local drawFunc = function ()
		local loveGraphics = love.graphics
		loveGraphics.push()
		local r,g,b,a = loveGraphics.getColor()
		loveGraphics.setColor(255,0,0,255)
		loveGraphics.translate( self.startX,self.startY + 16 )
		loveGraphics.line(0,0,self.diffX,self.diffY)
		loveGraphics.setColor(r,g,b,a)
		loveGraphics.pop()
	end
	self.lineNode = Scene.wrapNode({draw = drawFunc}, 9000)
	Game.scene:insert(self.lineNode)
	self.timeDisplayed = 0
	self.totalTime = 3
end

function ModLineFX:setEndPoints( startX,startY,endX,endY )
	self.startX = startX
	self.startY = startY
	self.diffX = endX - startX
	self.diffY = endY - startY
end

function ModLineFX:tick(dt)
	self.timeDisplayed = self.timeDisplayed + dt
	if self.timeDisplayed > self.totalTime then
		Game:del(self)
	end
end

function ModLineFX:destroy()
	Game.scene:remove(self.lineNode)
end

return ModLineFX