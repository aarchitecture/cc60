-- [draw loop]

function draw_title()
	if start_game then
		for i = 1, 15 do
			pal(i, start_game_flash <= title_flash_palette_threshold and ceil(max(start_game_flash) / title_flash_palette_divisor) or frames % title_flash_period < title_flash_on_frames and 7 or i)
		end
	end
	cls()
	if game_w == 240 then
		spr(47, game_w / 2 - 28, game_h / 2 - 32)
	elseif game_w == 480 then
		sspr(47, 0, 0, 56, 32, game_w / 2 - 56, game_h / 2 - 48, 112, 64)
	end
	center_print("\142 / \151", game_w / 2, game_h * 0.75 - 20, 5)
	center_print("made by", game_w / 2, game_h * 0.75, 5)
	center_print("lucidneon", game_w / 2, game_h * 0.75 + 7, 5)
	foreach(particles, draw_particle)
end

function draw_background()
	cls(flash_bg and frames / bg_flash_divisor or bg_col)
	foreach(clouds, function(c)
		c.x += c.spd - cam_spdx
		rectfill(c.x, c.y, c.x + c.w, c.y + 16 - c.w * 0.1875, cloud_col)
		if c.x > game_w then
			c.x = -c.w
			c.y = rnd(game_h)
		end
	end)
end

function on_screen(obj, pad)
	pad = pad or 0
	local x = obj.x
	local y = obj.y
	return x + 8 + pad >= draw_x and
		x - pad < draw_x + game_w and
		y + 8 + pad >= draw_y and
		y - pad < draw_y + game_h
end

function draw_world()
	draw_layer(4, lvl_x, lvl_y, 0, 0, lvl_w, lvl_h)
	draw_layer(3, lvl_x, lvl_y, 0, 0, lvl_w, lvl_h)
	for obj in all(draw_back) do
		if on_screen(obj, 8) then
			if obj.draw_below then
				obj:draw_below()
			else
				obj:draw()
			end
		end
	end
	draw_layer(2, lvl_x, lvl_y, 0, 0, lvl_w, lvl_h, 2)
	for obj in all(draw_front) do
		if on_screen(obj, 8) then
			obj:draw()
		end
	end
	draw_layer(2, lvl_x, lvl_y, 0, 0, lvl_w, lvl_h, 8)
end

function draw_effects()
	foreach(particles, draw_particle)
	foreach(dead_particles, function(p)
		p.x += p.dx
		p.y += p.dy
		p.t -= dead_particle_decay
		if p.t <= 0 then
			del(dead_particles, p)
		end
		rectfill(p.x - p.t, p.y - p.t, p.x + p.t, p.y + p.t, 14 + p.t * 5 % 2)
	end)
end

function draw_overlay()
	camera()
	if ui_timer >= ui_timer_min then
		if ui_timer < 0 then
			draw_ui()
		end
		ui_timer -= 1
	end
end

function _draw()
	if freeze > 0 then
		return
	end
	pal()

	if is_title() then
		draw_title()
		return
	end

	draw_background()
	draw_x, draw_y = get_camera_draw_offset()
	camera(draw_x, draw_y)
	draw_world()
	draw_effects()
	draw_overlay()
end

function draw_particle(p)
	p.x += p.spd - cam_spdx
	p.y += sin(p.off) - cam_spdy
	p.off += min(particle_phase_step_cap, p.spd / particle_phase_speed_divisor)
	rectfill(p.x + draw_x, p.y % game_h + draw_y, p.x + p.s + draw_x, p.y % game_h + p.s + draw_y, p.c)
	if p.x > game_w + 4 then
		p.x = -4
		p.y = rnd(game_h)
	elseif p.x < -4 then
		p.x = game_w
		p.y = rnd(game_h)
	end
end

function get_time_str()
	local ms_str = tostr(ms + 1000):sub(2)
	return two_digit_str(minutes \ 60) .. ":" .. two_digit_str(minutes % 60) .. ":" .. two_digit_str(seconds) .. "." .. ms_str
end

function draw_time(x, y)
	local time_str = get_time_str()
	local time_w = print(time_str, 0, -1000)
	rectfill(x, y, x + time_w + 1, y + 6, 0)
	print(time_str, x + 1, y + 1, 7)
end

function draw_ui()
	rectfill(game_w / 2 - 40, game_h / 2 - 6, game_w / 2 + 40, game_h / 2 + 4, 0)
	local title = lvl_title or lvl_id .. "00 m"
	center_print(title, game_w / 2, game_h / 2 - 2, 7)
	draw_time(4, 4)
end
