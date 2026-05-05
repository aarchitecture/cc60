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
	local down = btn(config.fixed_btn[action])
	if config.alt_dir_btn[action] then
		down = down or btn(config.alt_dir_btn[action])
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

function open_text_overlay(prompt, text, submit)
	text_overlay = {
		prompt = prompt or "",
		text = text or "",
		submit = submit,
	}
	window{pauseable = false}
	readtext(true)
end

function text_overlay_active()
	return text_overlay ~= nil
end

function close_text_overlay()
	text_overlay = nil
	window{pauseable = true}
	readtext(true)
end

function delete_text_overlay_char()
	if #text_overlay.text > 0 then
		text_overlay.text = sub(text_overlay.text, 1, #text_overlay.text - 1)
	end
end

function submit_text_overlay()
	local text = text_overlay.text
	local submit = text_overlay.submit
	close_text_overlay()
	if submit then
		submit(text)
	end
end

function update_text_overlay()
	local should_submit = false
	while peektext() do
		local txt = readtext()
		for i = 1, #txt do
			local ch = sub(txt, i, i)
			if ch == "\b" then
				delete_text_overlay_char()
			elseif ch == "\n" or ch == "\r" then
				should_submit = true
			else
				text_overlay.text ..= ch
			end
		end
	end

	if should_submit or keyp("enter") then
		submit_text_overlay()
	elseif keyp("delete") or keyp("backspace") then
		delete_text_overlay_char()
	elseif keyp("escape") then
		close_text_overlay()
	end
end

function fit_text_tail(text, w)
	while #text > 0 and print(text, 0, -1000) > w do
		text = sub(text, 2)
	end
	return text
end

function draw_text_overlay()
	camera()
	local w = min(game_w - 16, 180)
	local h = 28
	local x = flr((game_w - w) / 2)
	local y = flr((game_h - h) / 2)
	local text = fit_text_tail(text_overlay.text, w - 12)
	local cursor = frames % 30 < 15 and "_" or ""

	rectfill(x, y, x + w, y + h, 0)
	rect(x, y, x + w, y + h, 7)
	center_print(text_overlay.prompt, game_w / 2, y + 5, 7)
	print(text .. cursor, x + 6, y + 17, 6)
end

function get_camera_max_draw()
	local max_draw_x = max(level.pw - game_w, 0)
	local max_draw_y = max(level.ph - game_h, 0)

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
	return mid(cam.x - game_w / 2, 0, max_draw_x),
		mid(cam.y - game_h / 2, 0, max_draw_y)
end

function set_font(font)
	fetch("/system/fonts/" .. font .. ".font"):poke(0x4000)
	game_font = font
end
