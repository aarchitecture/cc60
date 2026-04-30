-- [constants]

fixed_btn = {
	left = 0,
	right = 1,
	up = 2,
	down = 3,
	jump = 4,
	dash = 5,
}

alt_dir_btn = {
	left = 8,		-- a
	right = 9,		-- d
	up = 10,			-- w
	down = 11,		-- s
}

title_flash_start = 100.0000000000000000					-- frame_count*2: round(50*2)
title_flash_end = -30.0000000000000000						-- unchanged
title_flash_palette_threshold = 20.0000000000000000	-- frame_count*2: round(10*2)
title_flash_palette_divisor = 10.0000000000000000		-- unchanged
title_flash_period = 20.0000000000000000					-- frame_count*2: round(10*2)
title_flash_on_frames = 10.0000000000000000				-- frame_count*2: round(5*2)
cloud_count = 33.0000000000000000							-- count*2: round(16.5*2)
cloud_speed_base = 0.5000000000000000						-- velocity*0.5
cloud_speed_range = 1.2000122070312500						-- fp2(262144,19661)
cloud_width_base = 32.0000000000000000						-- unchanged
cloud_width_range = 32.0000000000000000					-- unchanged
particle_count = 33.0000000000000000						-- count*1.32: round(25*1.32)
particle_size_range = 1.2500000000000000					-- unchanged
particle_speed_base = 0.1250000000000000					-- velocity*0.5
particle_speed_range = 1.5000152587890625					-- fp2(327680,19661)
particle_phase_step_cap = 0.0500000000000000				-- unchanged
particle_phase_speed_divisor = 32.0000000000000000		-- unchanged
dead_particle_decay = 0.1000076292548329					-- fp2(13107,32771)
dead_particle_start_t = 2.0000000000000000				-- unchanged
dead_particle_speed = 1.5000000000000000					-- velocity*0.5
ui_timer_min = -60.0000000000000000							-- frame_count*2: round(-30*2)
bg_flash_divisor = 10.0000000000000000						-- divisor*2: round(5*2)
level_title_delay = 10.0000000000000000					-- frame_count*2: round(5*2)

max_run = 1.0000000000000000									-- unchanged
ground_accel = 0.3077576472423971							-- accel_time: fp2(39322,33615)
air_accel = 0.1612096983008087								-- accel_time: fp2(26214,26413)
ice_accel = 0.0250015258789062								-- accel_time*0.5: fp2(3277,32768)
decel_speed = 0.0394278694875538								-- accel_distance: fp2(9830,17227)
max_fall = 1.5000000000000000									-- velocity*0.75
wall_slide_speed = 0.3892213557846844						-- velocity*adj: fp2(26214,63771)
fast_gravity_threshold = 0.2012018347159028				-- threshold*sqrt(2)*adj: fp2(9830,87910)
gravity = 0.0931096908170730									-- gravity_base: fp2(6881,58117)
ceiling_gravity_fast_scale = 1.3333000000000000			-- unchanged
ceiling_gravity_slow_divisor = 1.6666000000000000		-- unchanged
jump_velocity = -1.7554321289062500							-- jump_impulse: fp2(-131072,57522)
wall_jump_xboost = 0.5370483398437500						-- accel_distance: fp2(131072,17598)
wall_jump_check = 3.0000000000000000						-- unchanged
jump_buffer_frames = 8.0000000000000000					-- frame_count*2: round(4*2)
grace_frames = 12.0000000000000000							-- frame_count*2: round(6*2)

dash_speed = 0.9609222412109375								-- velocity*adj: fp2(327680,12595)
dash_empty_speed = 0.1921691894531250						-- velocity*(1/5): fp2(fp2(327680,12595),13107)
dash_time_frames = 8.0000000000000000						-- frame_count*2: round(4*2)
dash_target_speed = 1.6564025878906250						-- velocity*adj: fp2(131072,54277)
dash_target_rising_speed = 1.6036148071289062			-- velocity*adj: fp2(98304,70063)
dash_accel_speed = 0.2032699584960938						-- accel_distance: fp2(98304,8881)
dash_effect_frames = 20.0000000000000000					-- frame_count*2: round(10*2)
dash_freeze_frames = 4.0000000000000000					-- frame_count*2: round(2*2)
walk_anim_step = 0.1250000000000000							-- anim_step*0.5: fp2(16384,32768)

-- hair physics were modified
hair_count = 3
hair_y_offset = 0.5000000000000000							-- unchanged
hair_pull = 0.35													-- how strongly segments chase parent
hair_color = 8														-- matches the hair color in the sprite sheet
hair_colors = {
	[0] = 12,
	[1] = 8,
	[2] = { 11, 26, 7, 26 },									-- if it's a table, the colors are cycled through frame-by-frame in that order
}

landing_smoke_offset_y = 4.0000000000000000				-- unchanged
wall_slide_smoke_x = 6.0000000000000000					-- unchanged
wall_jump_smoke_x = 6.0000000000000000						-- unchanged
spawn_vertical_offset = 48.0000000000000000				-- unchanged
spawn_down_min_y = -4.0000000000000000						-- unchanged
spawn_up_speed = -2.0000000000000000						-- velocity*0.5: fp2(-262144,32768)
spawn_down_speed = 1.0000000000000000						-- unchanged
spawn_side_speed_x = 1.0000000000000000					-- unchanged
spawn_side_speed_y = -0.1250000000000000					-- velocity*0.5: fp2(-32768,16384)
spawn_side_offset_x = 20.0000000000000000					-- unchanged
spawn_apex_height = 16.0000000000000000					-- unchanged
spawn_apex_delay = 3.0000000000000000						-- unchanged
spawn_fall_accel = 0.1000061035156250						-- accel_distance: fp2(32768,13108)
spawn_fall_cap = 3.0000000000000000							-- unchanged
spawn_land_delay = 10.0000000000000000						-- frame_count*2: round(5*2)
restart_delay_frames = 15.0000000000000000				-- unchanged
spring_delta_divisor = 1.1250000000000000					-- unchanged
spring_trigger_delta = 1.0000000000000000					-- unchanged
spring_reset_delta = 8.0000000000000000					-- unchanged
spring_vertical_x_scale = 0.2000000000000000				-- unchanged
spring_vertical_y = -2.4999847412109375					-- velocity*adj: fp2(-196608,54613)
spring_horizontal_x = 2.0666198730468750					-- velocity*adj: fp2(196608,45146)
spring_horizontal_y = -1.1250000000000000					-- velocity*0.75: fp2(-98304,49152)
fall_floor_delay_step = 0.5000000000000000				-- unchanged
fall_floor_hidden_delay = 60.0000000000000000			-- unchanged
fall_floor_break_delay = 15.0000000000000000				-- unchanged
fall_floor_anim_divisor = 5.0000000000000000				-- unchanged

balloon_phase_step = 0.0049972534179688					-- phase_step*0.5: fp2(655,32768)
balloon_bob_height = 2.0000000000000000					-- pixel_height, unchanged
balloon_refill_frames = 60.0000000000000000				-- frame_count, unchanged
smoke_speed_x_base = 0.1500015258789062					-- velocity*0.5: fp2(19661,32768)
smoke_speed_x_range = 0.0999984741210938					-- velocity*0.5: fp2(13107,32768)
smoke_speed_y = -0.0500030517578125							-- velocity*0.5: fp2(-6554,32768)
smoke_sprite_step = 0.0999984741210938						-- anim_step*0.5: fp2(13107,32768)
fruit_phase_step = 0.0124969482421875						-- phase_step*0.5: fp2(1638,32768)
fruit_bob_height = 2.5000000000000000						-- pixel_height, unchanged
fly_fruit_sfx_delay = 8.0000000000000000					-- frame_count, unchanged
fly_fruit_sfx_delay_step = 0.5000000000000000			-- time_step, unchanged
fly_fruit_target_y = -2.0499801635742188					-- velocity*adj: fp2(-229376,38385)
fly_fruit_accel = 0.0749969482421875						-- accel*0.3: fp2(16384,19660)
fly_fruit_idle_step = 0.0250015258789062					-- phase_step*0.5: fp2(3277,32768)
fly_fruit_idle_amplitude = 0.1250000000000000			-- amplitude*0.5: fp2(32768,16384)
lifeup_rise_speed = -0.1250000000000000					-- velocity*0.5: fp2(-16384,32768)
lifeup_duration = 60.0000000000000000						-- frame_count*2: round(30*2)
lifeup_flash_step = 0.2500000000000000						-- flash_step*0.5: fp2(32768,32768)
lifeup_text_offset_x = 1.0000000000000000					-- pixel_offset*0.5: fp2(262144,16384)
fake_wall_bounce_x = -1.5000000000000000					-- impulse_velocity, unchanged
fake_wall_bounce_y = -1.5000000000000000					-- impulse_velocity, unchanged
chest_shake_frames = 40.0000000000000000					-- frame_count*2: round(20*2)
big_chest_open_frames = 120.0000000000000000				-- frame_count*2: round(60*2)
big_chest_particle_start_frames = 90.0000000000000000	-- frame_count*2: round(45*2)
big_chest_particle_cap = 50
big_chest_particle_x_base = 1.0000000000000000			-- unchanged
big_chest_particle_x_range = 14.0000000000000000		-- unchanged
big_chest_particle_height_base = 32.0000000000000000	-- unchanged
big_chest_particle_height_range = 32.0000000000000000	-- unchanged
big_chest_particle_speed_base = 4.0000000000000000		-- velocity*0.5
big_chest_particle_speed_range = 4.0000000000000000	-- velocity*0.5
big_chest_open_bg_col = 2
big_chest_open_cloud_col = 14
orb_sprite = 48
orb_rise_speed = -2.0000000000000000						-- velocity*0.5
orb_rise_decel = 0.1250000000000000							-- accel*0.25: fp2(8192,65536)
orb_collect_music_delay = 90.0000000000000000			-- frame_count*2: round(45*2)
orb_collect_freeze_frames = 20.0000000000000000			-- frame_count*2: round(10*2)
orb_djump_count = 2
orb_ring_period = 60.0000000000000000						-- frame_count*2: round(30*2)
orb_ring_radius = 8.0000000000000000						-- unchanged
orb_ring_color = 7
platform_speed = 0.3249969482421875							-- velocity*0.5: fp2(42598,32768)
message_index_step = 0.5000000000000000					-- text_step, unchanged
camera_deadzone_x = 12.0000000000000000					-- pixel deadzone
camera_deadzone_y = 8.0000000000000000						-- pixel deadzone

-- globals

objects = {}
by_type = {}
solids = {}
semis = {}
draw_back = {}
draw_front = {}
got_fruit = {}
cam_target = nil

freeze = 0
delay_restart = 0
music_timer = 0
ui_timer = -99
pause_player = false

draw_x, draw_y, cam_x, cam_y, cam_spdx, cam_spdy = 0, 0, 0, 0, 0, 0
