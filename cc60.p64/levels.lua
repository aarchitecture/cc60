-- [level loading]

local exit_dirs = { "up", "right", "left", "down" }
local layer_fallbacks = {
	objects = 1,
	ground = 2,
	deco = 3,
	background = 4,
}

function get_level_exits(meta)
	return meta.exits or {}
end

function level_has_exit(dir)
	return level and level.exits and level.exits[dir] ~= nil
end

function crossed_exit(dir, x, y)
	if dir == "up" then
		return y < -4
	elseif dir == "right" then
		return x > level.pw - 4
	elseif dir == "left" then
		return x < -4
	elseif dir == "down" then
		return y > level.ph - 4
	end
end

function should_exit_level(x, y)
	for dir in all(exit_dirs) do
		if level_has_exit(dir) and crossed_exit(dir, x, y) then
			return dir
		end
	end
end

function next_level(dir)
	local next_lvl = level.exits and level.exits[dir]
	local next_meta = next_lvl and levels[next_lvl]
	if not next_meta then
		return
	end

	if next_meta.music then
		music(next_meta.music, 100, 7)
	end
	if next_meta.bg_col then
		bg_col = next_meta.bg_col
	end
	if next_meta.cloud_col then
		cloud_col = next_meta.cloud_col
	end

	load_level(next_lvl, dir)
end

function clear_level_state()
	foreach(objects, destroy_object)
	objects = {}
	by_type = {}
	solids = {}
	semis = {}
	draw_back = {}
	draw_front = {}
	cam.target = nil
end

function load_level(id, enter_dir)
	local meta = levels[id]
	if not meta then
		return
	end

	has_dashed, has_key = false

	clear_level_state()
	cam.spdx, cam.spdy = 0, 0

	local prev_enter = level and level.enter
	local diff_level = not level or level.id ~= id

	level = {
		id = id,
		path = id,
		title = meta.title,
		summit = meta.summit == true,
		exits = get_level_exits(meta),
		enter = diff_level and (meta.enter or enter_dir or "up") or prev_enter or meta.enter or "up",
		map = fetch(id),
		layers = {},
	}

	for i, layer in ipairs(level.map) do
		if layer.name then
			level.layers[layer.name] = layer.bmp
		end
		for name, layer_i in pairs(layer_fallbacks) do
			if layer_i == i and not level.layers[name] then
				level.layers[name] = layer.bmp
			end
		end
	end

	level.w, level.h = level.map[1].bmp:attribs()
	level.pw, level.ph = level.w * 8, level.h * 8
	ui_timer = level_title_delay

	for layer in all(get_object_spawn_layers()) do
		for tx = 0, level.w - 1 do
			for ty = 0, level.h - 1 do
				local tile = layer:get(tx, ty)
				local object_type = tiles[tile] or tiles[tile - 0x4000]
				if object_type then
					init_object(object_type, tx * 8, ty * 8, tile)
				end
			end
		end
	end

	for obj in all(objects) do
		obj:ready()
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

function get_layer_bmp(layer)
	if type(layer) == "string" then
		return level.layers[layer]
	end

	local map_layer = level.map[layer or 1]
	return map_layer and map_layer.bmp
end

function get_object_spawn_layers()
	local spawn_layers = {}
	for layer in all(level.map) do
		if layer.name and sub(layer.name, 1, 7) == "objects" then
			add(spawn_layers, layer.bmp)
		end
	end

	if #spawn_layers == 0 and level.layers.objects then
		add(spawn_layers, level.layers.objects)
	end

	return spawn_layers
end

function tile_at(x, y, layer)
	local bmp = get_layer_bmp(layer or "objects")
	return bmp and bmp:get(x, y) or 0
end

function draw_layer(layer, ...)
	local bmp = get_layer_bmp(layer)
	if bmp then
		map(bmp, ...)
	end
end

function spikes_at(x1, y1, x2, y2, xspd, yspd)
	local left = max(0, x1 \ 8)
	local right = min(level.w - 1, x2 / 8)
	local top = max(0, y1 \ 8)
	local bottom = min(level.h - 1, y2 / 8)

	for i = left, right do
		for j = top, bottom do
			local tile = tile_at(i, j, "ground")

			if tile == 62 and y2 % 8 >= 6 and yspd >= 0
			or tile == 55 and y1 % 8 <= 2 and yspd <= 0
			or tile == 54 and x1 % 8 <= 2 and xspd <= 0
			or tile == 63 and x2 % 8 >= 6 and xspd >= 0
			or tile_at(i, j, "objects") == 43 then
				return true
			end
		end
	end
end
