-- [utility]

function rectangle(x, y, w, h)
	return { x = x, y = y, w = w, h = h }
end

function round(x)
	return flr(x + 0.5)
end

function appr(val, target, amount)
	return val > target and max(val - amount, target) or min(val + amount, target)
end

function sign(v)
	return v ~= 0 and sgn(v) or 0
end

function two_digit_str(x)
	return x < 10 and "0" .. x or x
end

function action_down(action)
	local down = btn(fixed_btn[action])
	if alt_dir_btn[action] then
		down = down or btn(alt_dir_btn[action])
	end
	return down
end

function action_pressed(action, prev)
	local down = action_down(action) and true or false
	local pressed = down and not prev[action]
	prev[action] = down
	return pressed
end

function center_print(text, x, y, c)
	local w = print(text, 0, -1000)
	print(text, x - w / 2, y, c)
end

function get_camera_max_draw()
	local max_draw_x = max(lvl_pw - game_w, 0)
	local max_draw_y = max(lvl_ph - game_h, 0)

	-- treat near-screen-sized rooms as locked to avoid a 1px wobble
	-- when tile dimensions do not divide cleanly into the viewport
	if max_draw_x <= 1 then
		max_draw_x = 0
	end
	if max_draw_y <= 1 then
		max_draw_y = 0
	end

	return max_draw_x, max_draw_y
end

function clamp_camera_target(target_x, target_y)
	local max_draw_x, max_draw_y = get_camera_max_draw()
	return mid(target_x, game_w / 2, game_w / 2 + max_draw_x),
		mid(target_y, game_h / 2, game_h / 2 + max_draw_y)
end

function get_camera_draw_offset()
	local max_draw_x, max_draw_y = get_camera_max_draw()
	return mid(cam_x - game_w / 2, 0, max_draw_x),
		mid(cam_y - game_h / 2, 0, max_draw_y)
end

function set_font(font)
	fetch("/system/fonts/" .. font .. ".font"):poke(0x4000)
	game_font = font
end
