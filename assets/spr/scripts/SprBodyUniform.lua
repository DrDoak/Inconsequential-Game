local ane = {
	stand = {
		row = 1,
		range = 1,
		downRow = 2,
		downRange = 1,
		upRow = 3,
		upRange = 1,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=0,x=0,y=0}},
						{"hand1",{angle=80,x=1,y=-1}}
						},
		attachDown = {{"neck",{angle=0,x=3,y=0,z=1}},
						{"hand1",{angle=0,x=-1,y=0,z=1}}
						},
		attachUp = {{"neck",{angle=0,x=3,y=0,z=-1}},
						{"hand1",{angle=0,x=-2,y=1,z=-1}}
					}
	},
	walk = {
		row = 1,
		range = 1,
		downRow = 2,
		downRange = 1,
		upRow = 3,
		upRange = 1,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=0,x=1,y=0}},
						{"hand1",{angle=90,x=0,y=-1.5}}},
		attachDown = {{"neck",{angle=0,x=3,y=0,z=1}},
						{"hand1",{angle=0,x=-1,y=0,z=1}}},
		attachUp = {{"neck",{angle=0,x=3,y=0,z=-1}},
						{"hand1",{angle=0,x=-2,y=1,z=-1}}}
	},
	aim_handgun = {
		row = 1,
		range = 2,
		downRow = 2,
		downRange = 2,
		upRow = 3,
		upRange = 2,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=10,x=6,y=-2}},
						{"hand1",{angle=0,x=16,y=12}}},
		attachDown = {{"neck",{angle=0,x=4,y=-2,z=1}},
						{"hand1",{angle=0,x=4,y=9,z=1}}},
		attachUp = {{"neck",{angle=0,x=0,y=-2,z=-1}},
						{"hand1",{angle=0,x=4,y=9,z=-1}}}
	},
	fire_handgun = {
		row = 1,
		range = 3,
		downRow = 2,
		downRange = 3,
		upRow = 3,
		upRange = 3,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=10,x=5,y=-2}},
						{"hand1",{angle=340,x=14,y=13}}},
		attachDown = {{"neck",{angle=0,x=3,y=-1,z=1}},
						{"hand1",{angle=0,x=4,y=10,z=1}}},
		attachUp = {{"neck",{angle=0,x=1,y=-2,z=-1}},
						{"hand1",{angle=0,x=4,y=10,z=-1}}}
	},
	hit = {
		row = 4,
		range = 1,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=25,x=7,y=-2}},
						{"hand1",{angle=340,x=14,y=13}}}
	}
}

local pce = {
	name = "body",
	path = "assets/spr/body/large_uniform.png",
	width = 100,
	height = 80,
	-- z =d 100,
	attachPoints = {
			center = {x = 48, y = 40},
			waist = {x = 46,y = 62},
			neck = {x = 46,y = 32},
			hand1 = {x = 43,y = 62}
		},
	connectSprite = "legs",
	connectPoint = "waist",
	connectMPoint = "waist",
	animations = ane
}
return pce