-- [initialization]

function _init()
	picotron_frames = 0
	frames = 0
	start_game_flash = 0

	music(40, 0, 7)
	lvl_id = 0

	set_font("p8")
end

function begin_game()
	max_djump = 1
	deaths = 0
	frames, seconds, minutes = 0, 0, 0
	music_timer = 0
	time_ticking = true
	fruit_count = 0
	flash_bg = false
	bg_col, cloud_col = 0, 1

	music(0, 0, 7)
	load_level(1)
end

function is_title()
	return lvl_id == 0
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
