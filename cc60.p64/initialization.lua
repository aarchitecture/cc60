-- [initialization]

function _init()
	frames = 0
	start_game_flash = 0
	start_game = false
	is_title = true
	title_input = {}
	init_dev_menu()

	music(40, 0, 7)
	level = nil

	set_font("p8")
end

function begin_game(map_path)
	map_path = map_path or config.start_map
	local meta = levels[map_path]
	if not meta then
		return
	end

	max_djump = 1
	deaths = 0
	frames, seconds, minutes = 0, 0, 0
	music_timer = 0
	time_ticking = true
	fruit_count = 0
	flash_bg = false
	bg_col, cloud_col = 0, 1
	is_title = false

	if meta.bg_col then
		bg_col = meta.bg_col
	end
	if meta.cloud_col then
		cloud_col = meta.cloud_col
	end

	music(meta.music or 0, 0, 7)
	load_level(map_path)
end

function open_map_prompt()
	if config.dev_mode then
		open_text_overlay("what map?", level and level.id or config.start_map, begin_game)
	end
end

function init_dev_menu()
	if menuitem and config.dev_mode then
		menuitem{
			id = "load_map",
			label = "Load map",
			action = open_map_prompt,
		}
	end
end

clouds = {}
for i = 0, cloud_count - 1 do
	add(clouds, {
		x = rnd(game_w),
		y = rnd(game_h),
		spd = cloud_speed_base + rnd(cloud_speed_range),
		w = cloud_width_base + rnd(cloud_width_range),
	})
end

particles = {}
for i = 0, particle_count - 1 do
	add(particles, {
		x = rnd(game_w),
		y = rnd(game_h),
		s = flr(rnd(particle_size_range)),
		spd = particle_speed_base + rnd(particle_speed_range),
		off = rnd(1),
		c = 6 + rnd(2),
	})
end

dead_particles = {}
