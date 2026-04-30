-- [level loading]

local game_map

function should_exit_level(x, y)
	if not levels[lvl_id + 1] then
		return false
	end

	if lvl_exit == "up" then
		return y < -4
	elseif lvl_exit == "right" then
		return x > lvl_pw - 4
	elseif lvl_exit == "left" then
		return x < -4
	elseif lvl_exit == "down" then
		return y > lvl_ph - 4
	end
end

function next_level()
	local next_lvl = lvl_id + 1
	if not levels[next_lvl] then
		return
	end

	if levels[next_lvl].music then
		music(levels[next_lvl].music, 100, 7)
	end
	if levels[next_lvl].bg_col then
		bg_col = levels[next_lvl].bg_col
	end
	if levels[next_lvl].cloud_col then
		cloud_col = levels[next_lvl].cloud_col
	end

	load_level(next_lvl)
end

function clear_level_state()
	foreach(objects, destroy_object)
	objects = {}
	by_type = {}
	solids = {}
	semis = {}
	draw_back = {}
	draw_front = {}
	cam_target = nil
end

function load_level(id)
	has_dashed, has_key = false

	clear_level_state()
	cam_spdx, cam_spdy = 0, 0

	local prev_lvl_id = lvl_id
	local prev_lvl_enter = lvl_enter
	local prev_lvl_exit = lvl_exit
	local diff_level = prev_lvl_id ~= id

	lvl_id = id

	local level = levels[lvl_id]
	lvl_title = level.title
	lvl_enter = diff_level and (level.enter or prev_lvl_exit) or prev_lvl_enter or level.enter or "up"
	lvl_exit = level.exit or "up"

	game_map = fetch(level.map)

	lvl_x, lvl_y, lvl_w, lvl_h = 0, 0, game_map[1].bmp:attribs()
	lvl_pw, lvl_ph = lvl_w * 8, lvl_h * 8
	ui_timer = level_title_delay

	for tx = 0, lvl_w - 1 do
		for ty = 0, lvl_h - 1 do
			local tile = tile_at(tx, ty)
			local object_type = tiles[tile] or tiles[tile - 0x4000]
			if object_type then
				init_object(object_type, tx * 8, ty * 8, tile)
			end
		end
	end
end

function get_mapdata(x, y, w, h)
	local reserve = ""
	for i = 0, w * h - 1 do
		local tile = mget(x + i % w, y + i \ w) & 0xff
		reserve ..= string.format("%02x", tile)
	end
	set_clipboard(reserve)
end

function replace_mapdata(x, y, w, h, data)
	for i = 1, #data, 2 do
		mset(x + i \ 2 % w, y + i \ 2 \ w, "0x" .. sub(data, i, i + 1))
	end
end

function tile_at(x, y, layer)
	return game_map[layer or 1].bmp:get(x, y)
end

function draw_layer(layer, ...)
	map(game_map[layer].bmp, ...)
end

function spikes_at(x1, y1, x2, y2, xspd, yspd)
	for i = max(0, x1 \ 8), min(lvl_w - 1, x2 / 8) do
		for j = max(0, y1 \ 8), min(lvl_h - 1, y2 / 8) do
			if ({
				[62] = y2 % 8 >= 6 and yspd >= 0,
				[55] = y1 % 8 <= 2 and yspd <= 0,
				[54] = x1 % 8 <= 2 and xspd <= 0,
				[63] = x2 % 8 >= 6 and xspd >= 0
			})[tile_at(i, j, 2)] then
				return true
			end
		end
	end
end
