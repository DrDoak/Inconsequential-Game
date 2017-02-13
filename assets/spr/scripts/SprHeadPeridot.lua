local ane = {
	stand = {
		row = 1,
		range = 1,
		downRow = 2,
		downRange = 1,
		upRow = 3,
		upRange = 1,
		delay = 0.1,
		priority = 1
	},
	walk = {
		row = 1,
		range = 1,
		downRow = 2,
		downRange = 1,
		upRow = 3,
		upRange = 1,
		delay = 0.1,
		priority = 1
	},
	aim_handgun = {
		row = 1,
		range = 2,
		downRow = 2,
		downRange = 2,
		upRow = 3,
		upRange = 3,
		delay = 0.1,
		priority = 1
	},
	fire_handgun = {
		row = 1,
		range = 2,
		downRow = 2,
		downRange = 3,
		upRow = 3,
		upRange = 2,
		delay = 0.1,
		priority = 1
	},
	run = {
		row = 1,
		range = 3,
		downRow = 2,
		downRange = 3,
		upRow = 3,
		upRange = 3,
		delay = 0.1,
		priority = 1
	},
	hit = {
		row = 4,
		range = 1,
		downRow = 2,
		downRange = 3,
		upRow = 3,
		upRange = 3,
		delay = 0.1,
		priority = 1
	},
}

local pce = {
	name = "head",
	path = "assets/spr/head/irrelevant.png",
	width = 64,
	height = 64,
	attachPoints = {
			center = {x = 31,y = 40},
			neck = {x = 31,y = 39}
		},
	connectSprite = "body",
	connectPoint = "neck",
	connectMPoint = "neck",
	animations = ane
}
return pce