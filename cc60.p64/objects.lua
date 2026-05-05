-- [objects]

function add_sorted(list, obj)
	for i, other in ipairs(list) do
		if obj.layer <= other.layer then
			add(list, obj, i)
			return
		end
	end
	add(list, obj)
end

function add_object(obj)
	add(objects, obj)

	if obj.type then
		if not by_type[obj.type] then
			by_type[obj.type] = {}
		end
		add(by_type[obj.type], obj)
	end

	if obj.solid_obj then
		add(solids, obj)
	end
	if obj.semisolid_obj then
		add(semis, obj)
	end

	if obj.layer < 0 or obj.draw_below then
		add_sorted(draw_back, obj)
	end
	if obj.layer >= 0 then
		add_sorted(draw_front, obj)
	end

	if obj.type == player or obj.type == player_spawn then
		cam.target = obj
	end
end

function remove_object(obj)
	del(objects, obj)
	if obj.type and by_type[obj.type] then
		del(by_type[obj.type], obj)
	end
	del(solids, obj)
	del(semis, obj)
	del(draw_back, obj)
	del(draw_front, obj)
	if cam.target == obj then
		cam.target = nil
	end
end

function nil_if_empty(list)
	return #list > 0 and list or nil
end

function init_object(type, x, y, tile, extra_data)
	local id = x .. "," .. y .. "," .. level.id
	if type.check_fruit and got_fruit[id] then
		return
	end

	local obj = {
		type = type,
		collideable = true,
		spr = tile,
		flip = {x = false, y = false},
		x = x,
		y = y,
		hitbox = rectangle(0, 0, 8, 8),
		spd = vec(0, 0),
		rem = vec(0, 0),
		layer = 0,

		fruit_id = id,
	}

	if tile and tile & 0x4000 > 0 then
		obj.flip.x = true
		obj.spr -= 0x4000
	end

	if extra_data then
		for k, v in pairs(extra_data) do
			obj[k] = v
		end
	end

	function obj.left() return obj.x + obj.hitbox.x end
	function obj.right() return obj.left() + obj.hitbox.w - 1 end
	function obj.top() return obj.y + obj.hitbox.y end
	function obj.bottom() return obj.top() + obj.hitbox.h - 1 end

	function obj.is_solid(ox, oy)
		for o in all(solids) do
			if o != obj and obj.objcollide(o, ox, oy) then
				return true
			end
		end
		if oy > 0 then
			for o in all(semis) do
				if o != obj and not obj.objcollide(o, ox, 0) and obj.objcollide(o, ox, oy) then
					return true
				end
			end
		end
		return oy > 0 and not obj.is_flag(ox, 0, 3) and obj.is_flag(ox, oy, 3) or
		obj.is_flag(ox, oy, 0)
	end

	function obj.is_ice(ox, oy)
		return obj.is_flag(ox, oy, 4)
	end

	function obj.is_flag(ox, oy, flag)
		ox = ox or 0
		oy = oy or 0
		for i = max(0, (obj.left() + ox) \ 8), min(level.w - 1, (obj.right() + ox) / 8) do
			for j = max(0, (obj.top() + oy) \ 8), min(level.h - 1, (obj.bottom() + oy) / 8) do
				if fget(tile_at(i, j, "ground"), flag) then
					return true
				end
			end
		end
	end

	function obj.objcollide(other, ox, oy)
		return other.collideable and
		other.right() >= obj.left() + ox and
		other.bottom() >= obj.top() + oy and
		other.left() <= obj.right() + ox and
		other.top() <= obj.bottom() + oy
	end

	function obj.check(type, ox, oy)
		local list = by_type[type]
		if list then
			for other in all(list) do
				if other and other ~= obj and obj.objcollide(other, ox, oy) then
					return other
				end
			end
		end
	end

	function obj.check_all(type, ox, oy)
		local hits = {}
		local list = by_type[type]
		if list then
			for other in all(list) do
				if other and other ~= obj and obj.objcollide(other, ox, oy) then
					add(hits, other)
				end
			end
		end

		return nil_if_empty(hits)
	end

	function obj.player_here()
		return obj.check(player, 0, 0)
	end

	function obj.move(ox, oy)
		for axis in all{"x", "y"} do
			local delta = axis == "x" and ox or oy
			obj.rem[axis] += delta
			local amt = round(obj.rem[axis])
			obj.rem[axis] -= amt
			local upmoving = axis == "y" and amt < 0
			local riding = not obj.player_here() and obj.check(player, 0, upmoving and amt or -1)
			local movamt
			if obj.collides then
				local step = sign(amt)
				local d = axis == "x" and step or 0
				local p = obj[axis]
				for i = 1, abs(amt) do
					if not obj.is_solid(d, step - d) then
						obj[axis] += step
					else
						obj.spd[axis], obj.rem[axis] = 0, 0
						break
					end
				end
				movamt = obj[axis] - p
			else
				movamt = amt
				if (obj.solid_obj or obj.semisolid_obj) and upmoving and riding then
					movamt += obj.top() - riding.bottom() - 1
					local hamt = round(riding.spd.y + riding.rem.y)
					hamt += sign(hamt)
					if movamt < hamt then
						riding.spd.y = max(riding.spd.y, 0)
					else
						movamt = 0
					end
				end
				obj[axis] += amt
			end
			if (obj.solid_obj or obj.semisolid_obj) and obj.collideable then
				obj.collideable = false
					local hit = obj.player_here()
					if hit and obj.solid_obj then
						hit.move(axis == "x" and (amt > 0 and obj.right() + 1 - hit.left() or amt < 0 and obj.left() - hit.right() - 1) or 0,
								axis == "y" and (amt > 0 and obj.bottom() + 1 - hit.top() or amt < 0 and obj.top() - hit.bottom() - 1) or 0)
						if obj.player_here() then
							kill_player(hit)
						end
					elseif riding then
						riding.move(axis == "x" and movamt or 0, axis == "y" and movamt or 0)
						if riding.hair then
							for h in all(riding.hair) do
								h.x += axis == "x" and movamt or 0
								h.y += axis == "y" and movamt or 0
							end
						end
					end
					obj.collideable = true
				end
			end
		end

	function obj.init_smoke(ox, oy)
		init_object(smoke, obj.x + (ox or 0), obj.y + (oy or 0), 21)
	end

	function obj:init() end
	function obj:update() end
	function obj:ready() end

	function obj:draw()
		spr(obj.spr, obj.x, obj.y, obj.flip.x, obj.flip.y)
	end

	obj.draw_sprite = obj.draw

	for k, v in pairs(type) do
		obj[k] = v
	end

	obj:init()
	add_object(obj)
	return obj
end

function destroy_object(obj)
	remove_object(obj)
end

function move_camera(obj)
	local focus_x = obj.x + 4
	local target_x = cam.x
	if focus_x < cam.x - camera_deadzone_x then
		target_x = focus_x + camera_deadzone_x
	elseif focus_x > cam.x + camera_deadzone_x then
		target_x = focus_x - camera_deadzone_x
	end

	local focus_y = obj.y
	local target_y = cam.y
	if focus_y < cam.y - camera_deadzone_y then
		target_y = focus_y + camera_deadzone_y
	elseif focus_y > cam.y + camera_deadzone_y then
		target_y = focus_y - camera_deadzone_y
	end

	target_x, target_y = clamp_camera_target(target_x, target_y)

	cam.spdx = target_x - cam.x
	cam.spdy = target_y - cam.y

	cam.x = target_x
	cam.y = target_y
end

include "objects/terrain.lua"
include "objects/collectibles.lua"
include "objects/special.lua"
