-- [terrain objects]

spring = {
	layer = -1,
}

function spring:init()
	self.delta = 0
	self.dir = self.flip.x and -1 or self.spr == 9 and 0 or 1
	self.show = true
end

function spring:update()
	self.delta = self.delta / spring_delta_divisor
	local hit = self.player_here()

	if self.show and hit and self.delta <= spring_trigger_delta then
		if self.dir == 0 then
			hit.move(0, self.y - hit.y - 4)
			hit.spd.x *= spring_vertical_x_scale
			hit.spd.y = spring_vertical_y
		else
			hit.move(self.x + self.dir * 4 - hit.x, 0)
			hit.spd = vec(self.dir * spring_horizontal_x, spring_horizontal_y)
		end
		hit.dash_time = 0
		hit.dash_effect_time = 0
		hit.djump = max_djump
		self.delta = spring_reset_delta
		sfx(8)
		self.init_smoke()

		break_fall_floor(self.check(fall_floor, -self.dir, self.dir == 0 and 1 or 0))
	end
end
function spring:draw()
	if self.show then
		local delta = min(flr(self.delta), 4)
		local x, y = self.x, self.y
		if self.dir == 0 then
			spr(9, x, y + delta)
		else
			spr(8, x + delta * -self.dir, y, self.flip.x)
		end
	end
end

fall_floor = {
	solid_obj = true,
	state = 0,
}

function fall_floor:update()
	if self.state == 0 then
		for i = 0, 2 do
			if self.check(player, i - 1, -(i % 2)) then
				break_fall_floor(self)
			end
		end
	elseif self.state == 1 then
		self.delay -= fall_floor_delay_step
		if self.delay <= 0 then
			self.state = 2
			self.delay = fall_floor_hidden_delay
			self.collideable = false
			set_springs(self, false)
		end
	elseif self.state == 2 then
		self.delay -= fall_floor_delay_step
		if self.delay <= 0 and not self.player_here() then
			sfx(7)
			self.state = 0
			self.collideable = true
			self.init_smoke()
			set_springs(self, true)
		end
	end
end

function fall_floor:draw()
	if self.state ~= 2 then
		spr(self.state == 1 and 35 - self.delay / fall_floor_anim_divisor or self.state == 0 and 32, self.x, self.y)
	end
end

function break_fall_floor(obj)
	if obj and obj.state == 0 then
		sfx(15)
		obj.state = 1
		obj.delay = fall_floor_break_delay
		obj.init_smoke()
	end
end

function set_springs(o, t)
	for s in all(by_type[spring]) do
		if abs(s.x - o.x) + abs(s.y - o.y) == 8 then
			s.show = t
		end
	end
end

platform = {
	layer = 2,
}

function platform:init()
	self.x -= 4
	self.hitbox.w = 16
	self.dir = self.flip.x and -1 or 1
	self.semisolid_obj = true
end
function platform:update()
	self.spd.x = self.dir * platform_speed
	if self.x < -16 then
		self.x = lvl_pw
	elseif self.x > lvl_pw then
		self.x = -16
	end
end
function platform:draw()
	spr(15, self.x, self.y - 1)
end
