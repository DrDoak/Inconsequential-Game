local ane = {
	main = {
		row = 1,
		range = 1,
		downRow = 3,
		downRange = 1,
		upRow = 2,
		upRange = 1,
		delay = 0.1,
		priority = 1,
	},
}

local pce = {
	name = "main",
	path = "assets/spr/fx/slash.png",
	width = 80,
	height = 80,
	vert = 32,
	imgX = 32,
	imgY = 32,--math.random(32,80),
	attachPoints = {center = {x=40,y=40}},
	animations = ane
}
return pce