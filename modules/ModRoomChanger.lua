local ModRoomChanger = Class.create("ModRoomChanger", Entity)
ModRoomChanger.dependencies = {"ModPhysics"}
function ModRoomChanger:setRoom( Room, x,y )
	self.nextX = x
	self.nextY = y
	self.nextRoom = Room
	self:setRoomChangeOnCollide(true)
end

function ModRoomChanger:setOneTime( oneTime )
	self.RoomChangeTemp = oneTime
end
function ModRoomChanger:changeRoom( character ,room)
	room = room or self.nextRoom
	--if character:getTimeInRoom() > 0.1 then
		local x,y = character.body:getPosition()
		local nextX = x
		if self.nextX then
			nextX = tonumber(self.nextX)* 32 + 16
		end
		local nextY = y
		if self.nextY then
			nextY = tonumber(self.nextY) * 32 
		end
		character:setPosition( nextX, nextY )

		local name = "assets/rooms/"..room --self.nextRoom
		lume.trace(nextX,nextY)
		Game.worldManager:moveCharacter(character,name)

		if character:hasModule("ModControllable") then
			lume.trace()
			self:playerChangeRoom( character )
		end

		if self.RoomChangeTemp then
			Game:del(self)
		end
	--end
end

function ModRoomChanger:setRoomChangeOnCollide( roomChange )
	self.roomChangeOnCollide = roomChange
end

function ModRoomChanger:onCollide(other, collision)
	if self.setRoomChangeOnCollide and Class.istype(other, "ObjBase")  and (other:hasModule("ModCharacter")) then
		self:changeRoom(other)
	end
end

function ModRoomChanger:playerChangeRoom(other)
	lume.trace(other.type)
	if other:hasModule("ModCharacter") then
		local player = Game.player
		lume.trace()
		Log.debug("ObjLevelChanger detected collision with ObjChar")
		local x,y = other.body:getPosition()
		local newX = self.newX and tonumber(self.newX)* 16 or x
		local newY = self.newY and tonumber(self.newY) * 16 or y
		other:setPosition( newX, newY )
		-- Gamestate.push( FadeState, {0,0,0,0}, {0,0,0,255},0.3)
		local name = self.nextRoom
		if string.sub(self.nextRoom,1,6) ~= "assets" then
			name = "assets/rooms/"..self.nextRoom
		end
		Game.worldManager:loadRoom( name, self.dir ,self.prevX, self.prevY,newX,newY)
		if self.temp then
			Game:del(self)
		end
	end
end
return ModRoomChanger