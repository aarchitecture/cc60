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

function set_font(font)
	fetch("/system/fonts/" .. font .. ".font"):poke(0x4000)
	game_font = font
end
