-- [player class]

player = {
	layer = 1,
	collides = true,
	clamps = true,
}
function player:init()
	self.grace, self.jbuffer = 0, 0
	self.djump = max_djump
	self.dash_time, self.dash_effect_time = 0, 0
	self.dash_target_x, self.dash_target_y = 0, 0
	self.dash_accel_x, self.dash_accel_y = 0, 0
	self.prev_input = {}
	self.hitbox = rectangle(1, 3, 6, 5)
	self.spr_off = 0
	self.dash_recharge_block = 0
end

function player:update()
	if pause_player then
		return
	end

	local input_x = action_down("right") and 1 or action_down("left") and -1 or 0
	local input_y = action_down("up") and -1 or action_down("down") and 1 or 0
	local dead = false

	if spikes_at(self.left(), self.top(), self.right(), self.bottom(), self.spd.x, self.spd.y) then
		kill_player(self)
		dead = true
	end

	if self.y > lvl_ph and lvl_exit ~= "down" then
		kill_player(self)
		dead = true
	end

	if dead then
		return
	end

	local on_ground = self.is_solid(0, 1)

	if on_ground and not self.was_on_ground then
		self.init_smoke(0, landing_smoke_offset_y)
	end

	local jump = action_pressed("jump", self.prev_input)
	local dash = action_pressed("dash", self.prev_input)

	if jump then
		self.jbuffer = jump_buffer_frames
	elseif self.jbuffer > 0 then
		self.jbuffer -= 1
	end

	if on_ground then
		self.grace = grace_frames
		if self.djump < max_djump
		and self.dash_recharge_block == 0 then
			sfx(54)
			self.djump = max_djump
		end
	elseif self.grace > 0 then
		self.grace -= 1
	end

	if self.dash_recharge_block > 0 then
		self.dash_recharge_block -= 1
	end

	self.dash_effect_time = max(0, self.dash_effect_time - 1)

	if self.dash_time > 0 then
		self.init_smoke()
		self.dash_time -= 1
		local dash_x = appr(self.spd.x, self.dash_target_x, self.dash_accel_x)
		local dash_y = appr(self.spd.y, self.dash_target_y, self.dash_accel_y)

		-- bonks zero y speed in move(), but at 60fps the scaled dash accel is too
		-- small to reliably reassert vertical carry through subpixel rounding
		-- restore dash vertical intent immediately so the vanilla dash quirk survives
		if self.spd.y == 0 and self.dash_target_y ~= 0 and not on_ground then
			dash_y = self.dash_target_y
		end

		self.spd = vec(dash_x, dash_y)
	else
		-- horizontal movement uses different acceleration curves for ground, air, and ice
		local accel = self.is_ice(0, 1) and ice_accel or on_ground and ground_accel or air_accel
		local decel = decel_speed

		self.spd.x = abs(self.spd.x) <= max_run and
		appr(self.spd.x, input_x * max_run, accel) or
		appr(self.spd.x, sign(self.spd.x) * max_run, decel)

		if self.spd.x ~= 0 then
			self.flip.x = self.spd.x < 0
		end

		local maxfall = max_fall

		if input_x ~= 0 and self.is_solid(input_x, 0) and not self.is_ice(input_x, 0) then
			maxfall = wall_slide_speed
			if rnd(10) < 2 then
				self.init_smoke(input_x * wall_slide_smoke_x)
			end
		end

		if not on_ground then
			self.spd.y = appr(self.spd.y, maxfall, abs(self.spd.y) > fast_gravity_threshold and gravity or gravity / 2)
		elseif self.spd.y > 0 then
			self.spd.y = 0
		end

		if self.jbuffer > 0 then
			if self.grace > 0 then
				sfx(1)
				self.jbuffer = 0
				self.grace = 0
				self.spd.y = jump_velocity
				self.init_smoke(0, landing_smoke_offset_y)
			else
				local wall_dir = (self.is_solid(-wall_jump_check, 0) and -1 or self.is_solid(wall_jump_check, 0) and 1 or 0)
				if wall_dir ~= 0 then
					sfx(2)
					self.jbuffer = 0
					self.spd = vec(-wall_dir * (max_run + wall_jump_xboost), jump_velocity)
					if not self.is_ice(wall_dir * wall_jump_check, 0) then
						self.init_smoke(wall_dir * wall_jump_smoke_x)
					end
				end
			end
		end

		local d_full = dash_speed
		local d_half = dash_speed / sqrt(2)

		if self.djump > 0 and dash then
			self.init_smoke()
			self.djump -= 1
			self.dash_recharge_block = 2
			self.dash_time = dash_time_frames
			has_dashed = true
			self.dash_effect_time = dash_effect_frames

			local no_vert = input_y == 0
			if input_x == 0 then
				self.spd = vec(no_vert and (self.flip.x and -dash_empty_speed or dash_empty_speed) or 0, input_y * d_full)
			else
				self.spd = vec(input_x * (no_vert and d_full or d_half), input_y * d_half)
			end

			sfx(3)
			freeze = dash_freeze_frames

			self.dash_target_x = dash_target_speed * sign(self.spd.x)
			self.dash_target_y = (self.spd.y >= 0 and dash_target_speed or dash_target_rising_speed) * sign(self.spd.y)
			self.dash_accel_x = self.spd.y == 0 and dash_accel_speed or dash_accel_speed / sqrt(2)
			self.dash_accel_y = self.spd.x == 0 and dash_accel_speed or dash_accel_speed / sqrt(2)
		elseif self.djump <= 0 and dash then
			sfx(9)
			self.init_smoke()
		end
	end

	self.spr_off += walk_anim_step
	self.spr = not on_ground and (self.is_solid(input_x, 0) and 5 or 3) or
	action_down("down") and 6 or
	action_down("up") and 7 or
	self.spd.x ~= 0 and input_x ~= 0 and 1 + self.spr_off % 4 or 1

	self.was_on_ground = on_ground

	if should_exit_level(self.x, self.y) then
		next_level()
	end
end

function player:draw()
	set_hair_color(self.djump)
	draw_hair(self)
	self:draw_sprite()
	pal()
end

function init_hair(obj)
	obj.hair = {}

	local rootx =
		obj.x + (obj.flip.x and 5 or 3)

	local rooty =
		obj.y + 3

	for i=1,hair_count do
		add(obj.hair,{
			x=rootx,
			y=rooty
		})
	end
end

function get_hair_color(djump)
	local col = hair_colors[djump]
	local total_frames = seconds * 60 + frames

	if type(col) == "table" then
		local index = (total_frames \ 3) % #col + 1
		col = col[index]
	end

	return col
end

function set_hair_color(djump)
	pal(hair_color, get_hair_color(djump))
end

function draw_hair(obj)
	local lastx =
		obj.x + (obj.flip.x and 5 or 3)

	local lasty = obj.y + (action_down("down") and 4 or 3)

	for i,h in ipairs(obj.hair) do
		-- simple pulling force
		local tx = lastx
		local ty = lasty + hair_y_offset

		h.x += (tx - h.x) * hair_pull
		h.y += (ty - h.y) * hair_pull

		-- draw
		circfill(
			h.x,
			h.y,
			mid(4-i,1.8,2),
			hair_color
		)

		lastx = h.x
		lasty = h.y
	end
end

function kill_player(obj)
	sfx(0)
	deaths += 1
	destroy_object(obj)

	for dir = 0, 0.875, 0.125 do
		add(dead_particles, {
			x = obj.x + 4,
			y = obj.y + 4,
			t = dead_particle_start_t,
			dx = sin(dir) * dead_particle_speed,
			dy = cos(dir) * dead_particle_speed
		})
	end
	delay_restart = restart_delay_frames
end

player_spawn = {
	layer = 6,
	draw = player.draw
}
function player_spawn:init()
	sfx(4)
	self.spr = 3
	self.target = self.y

	if lvl_enter == "up" then
		self.y = min(self.y + spawn_vertical_offset, lvl_ph)
		self.spd.y = spawn_up_speed
	elseif lvl_enter == "down" then
		self.y = max(self.y - spawn_vertical_offset, spawn_down_min_y)
		self.spd.y = spawn_down_speed
	elseif lvl_enter == "right" then
		self.spd = vec(spawn_side_speed_x, spawn_side_speed_y)
		self.x -= spawn_side_offset_x
	elseif lvl_enter == "left" then
		self.spd = vec(-spawn_side_speed_x, spawn_side_speed_y)
		self.x += spawn_side_offset_x
		self.flip.x = true
	end

	cam_x, cam_y = mid(self.x + 4, 64, lvl_pw - 64), mid(self.y, 64, lvl_ph - 64)

	self.state = 0
	self.delay = 0

	init_hair(self)
	self.djump = max_djump
end
function player_spawn:update()
	if self.state == 0 and self.y < self.target + spawn_apex_height then
		self.state = 1
		if lvl_enter ~= "down" then
			self.delay = spawn_apex_delay
		end
	elseif self.state == 1 then
		self.spd.y += spawn_fall_accel
		self.spd.y = min(self.spd.y, spawn_fall_cap)

		if self.spd.y > 0 then
			if self.delay > 0 then
				self.spd.y = 0
				self.delay -= 1
			elseif self.y > self.target then
				self.y = self.target
				self.spd = vec(0, 0)
				self.state = 2
				self.delay = spawn_land_delay
				self.init_smoke(0, landing_smoke_offset_y)
				sfx(5)
			end
		end
	elseif self.state == 2 then
		self.delay -= 1
		self.spr = 6
		if self.delay < 0 then
			destroy_object(self)
			local p = init_object(player, self.x, self.y)
			p.hair = self.hair
			p.flip.x = self.flip.x
		end
	end
end
