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
		attachMod = {{"neck",{angle=0,x=2,y=0}},
						{"hand1",{angle=80,x=1,y=-1}}
						},
		attachDown = {{"neck",{angle=0,x=0,y=2,z=-1}},
						{"hand1",{angle=0,x=0,y=0,z=1}}
						},
		attachUp = {{"neck",{angle=0,x=0,y=0,z=1}},
						{"hand1",{angle=0,x=0,y=1,z=-1}}
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
		attachMod = {{"neck",{angle=10,x=2,y=0}},
						{"hand1",{angle=90,x=0,y=-1.5}}},
		attachDown = {{"neck",{angle=0,x=0,y=2,z=-1}},
						{"hand1",{angle=0,x=0,y=0,z=1}}
						},
		attachUp = {{"neck",{angle=0,x=0,y=0,z=1}},
						{"hand1",{angle=0,x=0,y=1,z=-1}}
					}
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
		attachMod = {{"neck",{angle=0,x=3,y=0.5}},
						{"hand1",{angle=0,x=13,y=12}}},
		attachDown = {{"neck",{angle=0,x=2,y=0,z=-1}},
						{"hand1",{angle=0,x=0,y=9,z=1}}},
		attachUp = {{"neck",{angle=0,x=0,y=-1,z=1}},
						{"hand1",{angle=0,x=0,y=9,z=-1}}}
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
		attachMod = {{"neck",{angle=10,x=2,y=0.5}},
						{"hand1",{angle=340,x=11,y=12}}},
		attachDown = {{"neck",{angle=0,x=1.5,y=0.5,z=-1}},
						{"hand1",{angle=0,x=0,y=10,z=1}}},
		attachUp = {{"neck",{angle=0,x=1,y=-2,z=1}},
						{"hand1",{angle=0,x=0,y=10,z=-1}}}
	},
	run = {
		row = 1,
		range = 4,
		downRow = 2,
		downRange = 4,
		upRow = 3,
		upRange = 4,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=10,x=5,y=-1}},
						{"hand1",{angle=140,x=-10,y=7}}},
		attachDown = {{"neck",{angle=0,x=0,y=-1,z=-1}},
						{"hand1",{angle=30,x=-7.5,y=1.5,z=1}}
						},
		attachUp = {{"neck",{angle=0,x=0,y=0,z=1}},
						{"hand1",{angle=330,x=6.5,y=2.5,z=-1}}
					}
	},
	slash_p = {
		row = 4,
		range = 1,
		downRow = 5,
		downRange = 1,
		upRow = 5,
		upRange = 3,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=10,x=6,y=-2}},
						{"hand1",{angle=330,x=12,y=14}}},
		attachDown = {{"neck",{angle=0,x=1,y=-2,z=-1}},
						{"hand1",{angle=230,x=9,y=10,z=1}}
						},
		attachUp = {{"neck",{angle=0,x=-1,y=-2,z=1}},
						{"hand1",{angle=100,x=-9,y=10,z=1}}
					}
	},
	slash = {
		row = 4,
		range = 2,
		downRow = 5,
		downRange = 2,
		upRow = 5,
		upRange = 4,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=10,x=6,y=-2}},
						{"hand1",{angle=160,x=-10,y=12}}},
		attachDown = {{"neck",{angle=0,x=0,y=-1,z=-1}},
						{"hand1",{angle=230,x=-12,y=12,z=1}}
						},
		attachUp = {{"neck",{angle=0,x=2,y=-2,z=1}},
						{"hand1",{angle=100,x=15,y=-1,z=1}}
					}
	},
	hit = {
		row = 6,
		range = 1,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=10,x=5,y=-1}},
						{"hand1",{angle=30,x=8,y=4}}},
	}
}

local pce = {
	name = "body",
	path = "assets/spr/body/irrelevant.png",
	width = 64,
	height = 64,
	-- z = 100,
	attachPoints = {
			waist = {x = 32,y = 56},
			neck = {x = 31,y = 28},
			hand1 = {x=32,y=56}
		},
		-- attachPoints = {
		-- 	center = {x = 48, y = 40},
		-- 	waist = {x = 46,y = 62},
		-- 	neck = {x = 46,y = 32},
		-- 	hand1 = {x = 43,y = 62}
		-- },
	connectSprite = "legs",
	connectPoint = "waist",
	connectMPoint = "waist",
	animations = ane
}
return pce