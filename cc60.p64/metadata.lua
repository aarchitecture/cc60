-- [metadata]

-- level table
-- levels is keyed by map file.
-- exits maps directions to destination maps.
levels = {
	["map/0.map"] = {
		title = "100 m",
		exits = {
			up = "map/2.map",
		},
	},
	["map/2.map"] = {
		title = "evergreen foothills",
		music = 20,
		exits = {
			right = "map/1.map",
		},
		bg_col = 21,
		cloud_col = 22,
	},
	["map/1.map"] = {
		title = "summit",
		music = 30,
		summit = true,
	},
}

-- tiles stack
-- assigned objects will spawn from tiles set here
tiles = {
	[1] = player_spawn,
	[8] = spring,
	[9] = spring,
	[11] = chest,
	[12] = message,
	[13] = big_chest,
	[14] = fake_wall,
	[15] = platform,
	[16] = flag,
	[19] = balloon,
	[20] = fruit,
	[24] = berry_key,
	[32] = fall_floor,
	[40] = fly_fruit,
}
