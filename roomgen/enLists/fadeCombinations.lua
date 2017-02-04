local enList = {

	{ --Standard Knife Fighter
		enemies = {
			{
				eType = "EnFade",
				params = {weapon="EqpKnife"},
				zone = "ground"
			}
		},
		probabilityWeight = 10,
		value = 10,
	},
	{ --Just a bottle man by himself
		enemies = {
			{
				eType = "EnFade",
				params = {weapon="EqpBottle"},
				zone = "ground"
			}
		},
		probabilityWeight = 10,
		value = 10,
	},
	{ --Just a Staff Man by himself
		enemies = {
			{
				eType = "EnFade",
				params = {weapon="EqpStaff"},
				zone = "ground"
			}
		},
		probabilityWeight = 10,
		value = 10,
	},
	{ -- A staff man and a dagger man
		enemies = {
			{
				eType = "EnFade",
				params = {weapon="EqpBottle"},
				zone = "ground"
			},
			{
				eType = "EnFade",
				params = {weapon="EqpDagger"},
				zone = "ground"
			}
		},
		probabilityWeight = 10,
		value = 10,
	},
	{ -- A staff man and a dagger man
		enemies = {
			{
				eType = "EnFade",
				params = {weapon="EqpBottle"},
				zone = "ground"
			},
			{
				eType = "EnFade",
				params = {weapon="EqpDagger"},
				zone = "ground"
			}
		},
		probabilityWeight = 10,
		value = 10,
	},
}

return enList