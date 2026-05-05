-- 60fps celeste classic
-- originally off evercore and evertron but i think i've diverged a LOT
-- made by lucidneon

config = {
	vid_mode = 3,
	dev_mode = false,
	draw_hitboxes = false,
	start_map = "map/0.map",
	static_balloons = false,
	fix_evercore_keys = true,
	fix_key_wobble = false,
	fix_player_anim_slide = false,

	fixed_btn = {
		left = 0,
		right = 1,
		up = 2,
		down = 3,
		jump = 4,
		dash = 5,
	},

	alt_dir_btn = {
		left = 8,		-- a
		right = 9,		-- d
		up = 10,			-- w
		down = 11,		-- s
	},

	default_hair_color = 8,	-- match the hair color in the sprite sheet
	hair_colors = {
		[0] = 12,
		[1] = 8,	-- this should probably be the same as your default
		[2] = { 11, 26, 7, 26 },	-- if it's a table, the colors are cycled through frame-by-frame in that order
	},
}

vid(config.vid_mode)
game_w, game_h = get_display():attribs()

include("constants.lua")
include("globals.lua")
include("util.lua")
include("initialization.lua")
include("update.lua")
include("draw.lua")
include("player.lua")
include("objects.lua")
include("levels.lua")
include("metadata.lua")
