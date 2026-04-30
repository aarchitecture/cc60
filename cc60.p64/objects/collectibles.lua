-- [collectible objects]

-- strawberry variants and reward popups
fruit = {
	check_fruit = true
}

function fruit:init()
	self.start = self.y
	self.off = 0
end

function fruit:update()
	check_fruit(self)
	self.off += fruit_phase_step
	self.y = self.start + sin(self.off) * fruit_bob_height
end

fly_fruit = {
	check_fruit = true
}

function fly_fruit:init()
	self.start = self.y
	self.step = 0.5
	self.sfx_delay = fly_fruit_sfx_delay
end

function fly_fruit:update()
	if has_dashed then
		if self.sfx_delay > 0 then
			self.sfx_delay -= fly_fruit_sfx_delay_step
			if self.sfx_delay <= 0 then
				sfx(14)
			end
		end
		self.spd.y = appr(self.spd.y, fly_fruit_target_y, fly_fruit_accel)
		if self.y < -16 then
			destroy_object(self)
		end
	else
		self.step += fly_fruit_idle_step
		self.spd.y = sin(self.step) * fly_fruit_idle_amplitude
	end
	check_fruit(self)
end

function fly_fruit:draw()
	local x, y = self.x, self.y
	spr(20, x, y)
	for ox = -6, 6, 12 do
		spr((has_dashed or sin(self.step) >= 0) and 40 or self.y > self.start and 42 or 41, x + ox, y - 2, ox == -6)
	end
end

function check_fruit(self)
	local hit = self.player_here()
	if hit then
		hit.djump = max_djump
		sfx(13)
		got_fruit[self.fruit_id] = true
		init_object(lifeup, self.x, self.y)
		destroy_object(self)
		if time_ticking then
			fruit_count += 1
		end
	end
end

lifeup = {}

function lifeup:init()
	self.spd.y = lifeup_rise_speed
	self.duration = lifeup_duration
	self.flash = 0
end

function lifeup:update()
	self.duration -= 1
	if self.duration <= 0 then
		destroy_object(self)
	end
end

function lifeup:draw()
	self.flash += lifeup_flash_step
	?"1000", self.x - lifeup_text_offset_x, self.y - 4, 7 + self.flash % 2
end

function init_fruit(self, ox, oy)
	sfx(16)
	init_object(fruit, self.x + ox, self.y + oy, 20).fruit_id = self.fruit_id
	destroy_object(self)
end

-- strawberry spawners and key progression
fake_wall = {
	check_fruit = true,
	solid_obj = true
}
function fake_wall:init()
	self.solid_obj = true
	self.hitbox = rectangle(0, 0, 16, 16)
end
function fake_wall:update()
	self.hitbox = rectangle(-1, -1, 18, 18)
	local hit = self.player_here()
	if hit and hit.dash_effect_time > 0 then
		hit.spd = vec(sign(hit.spd.x) * fake_wall_bounce_x, fake_wall_bounce_y)
		hit.dash_time = -1
		for ox = 0, 8, 8 do
			for oy = 0, 8, 8 do
				self.init_smoke(ox, oy)
			end
		end
		init_fruit(self, 4, 4)
	end
	self.hitbox = rectangle(0, 0, 16, 16)
end
function fake_wall:draw()
	spr(14, self.x, self.y)
end

berry_key = {}
function berry_key:update()
	self.spr = flr(25.5 + sin(frames / 60))
	if frames == 36 then
		self.flip.x = not self.flip.x
	end
	if self.player_here() then
		sfx(23)
		destroy_object(self)
		has_key = true
	end
end

chest = {
	check_fruit = true
}
function chest:init()
	self.x -= 4
	self.start = self.x
	self.timer = chest_shake_frames
end
function chest:update()
	if has_key then
		self.timer -= 1
		self.x = self.start - 1 + rnd(3)
		if self.timer <= 0 then
			init_fruit(self, 0, -4)
		end
	end
end

-- dash refill
balloon = {}

function balloon:init()
	self.offset = rnd(1)
	self.start = self.y
	self.timer = 0
	self.hitbox = rectangle(-1, -1, 10, 10)
	self.show = true
end

function balloon:update()
	if self.show then
		self.offset += balloon_phase_step
		self.y = self.start + sin(self.offset) * balloon_bob_height
		local hit = self.player_here()
		if hit and hit.djump < max_djump then
			sfx(6)
			self.init_smoke()
			hit.djump = max_djump
			self.show = false
			self.timer = balloon_refill_frames
		end
	elseif self.timer > 0 then
		self.timer -= 1
	else
		sfx(7)
		self.init_smoke()
		self.show = true
	end
end

function balloon:draw()
	if self.show then
		local x, y = self.x, self.y
		for i = 7, 13 do
			pset(x + 4 + sin(self.offset * 2 + i / 10), y + i, 6)
		end
		self:draw_sprite()
	end
end

-- double dash
big_chest = {}
function big_chest:init()
	self.state = max_djump >= orb_djump_count and 2 or 0
	self.hitbox.w = 16
end
function big_chest:update()
	if self.state == 0 then
		local hit = self.check(player, 0, 8)
		if hit and hit.is_solid(0, 1) then
			music(-1, 500, 7)
			sfx(37)
			pause_player = true
			hit.spd = vec(0, 0)
			self.state = 1
			self.init_smoke()
			self.init_smoke(8)
			self.timer = big_chest_open_frames
			self.particles = {}
		end
	elseif self.state == 1 then
		self.timer -= 1
		flash_bg = true
		if self.timer <= big_chest_particle_start_frames and #self.particles < big_chest_particle_cap then
			add(self.particles, {
				x = big_chest_particle_x_base + rnd(big_chest_particle_x_range),
				y = 0,
				h = big_chest_particle_height_base + rnd(big_chest_particle_height_range),
				spd = big_chest_particle_speed_base + rnd(big_chest_particle_speed_range)
			})
		end
		if self.timer < 0 then
			self.state = 2
			self.particles = {}
			flash_bg, bg_col, cloud_col = false, big_chest_open_bg_col, big_chest_open_cloud_col
			init_object(orb, self.x + 4, self.y + 4, orb_sprite)
			pause_player = false
		end
	end
end
function big_chest:draw()
	if self.state == 0 then
		self:draw_sprite()
	elseif self.state == 1 then
		foreach(self.particles, function(p)
			p.y += p.spd
			line(self.x + p.x, self.y + 8 - p.y, self.x + p.x, min(self.y + 8 - p.y + p.h, self.y + 8), 7)
		end)
	end
	sspr(self.spr, 0, 8, 16, 8, self.x, self.y + 8)
end

orb = {}
function orb:init()
	self.spd.y = orb_rise_speed
end
function orb:update()
	self.spd.y = appr(self.spd.y, 0, orb_rise_decel)
	local hit = self.player_here()
	if self.spd.y == 0 and hit then
		music_timer = orb_collect_music_delay
		sfx(51)
		freeze = orb_collect_freeze_frames
		destroy_object(self)
		max_djump = orb_djump_count
		hit.djump = orb_djump_count
	end
end
function orb:draw()
	local total_frames = seconds * 60 + frames
	self:draw_sprite()
	for i = 0, 0.875, 0.125 do
		circfill(self.x + 4 + cos(total_frames / orb_ring_period + i) * orb_ring_radius, self.y + 4 + sin(total_frames / orb_ring_period + i) * orb_ring_radius, 1, orb_ring_color)
	end
end
