-- [special objects]

-- transient effects
smoke = {
	layer = 3
}

function smoke:init()
	self.spd = vec(smoke_speed_x_base + rnd(smoke_speed_x_range), smoke_speed_y)
	self.x += -1 + rnd(2)
	self.y += -1 + rnd(2)
	self.flip = {x = rnd() < 0.5, y = rnd() < 0.5}
end

function smoke:update()
	self.spr += smoke_sprite_step
	if self.spr >= 24 then
		destroy_object(self)
	end
end

-- interactable world text
message = {
	layer = 4
}
function message:init()
	self.text = "-- celeste mountain --#this memorial to those# perished on the climb"
	self.hitbox.x += 4
	self.hitbox.y += 8
	self.index = 0
	self.last = 0
end
function message:draw()
	if self.check(player, 4, 0) then
		if self.index < #self.text then
			self.index += message_index_step
			if self.index >= self.last + 1 then
				self.last += 1
				sfx(35)
			end
		end
		local x, y = game_w / 2 - 56, game_h - 32
		local line_start_x = x
		camera()
		for i = 1, self.index do
			if sub(self.text, i, i) ~= "#" then
				rectfill(x - 2, y - 2, x + 7, y + 6, 7)
				?sub(self.text, i, i), x, y, 0
				x += 5
			else
				x = line_start_x
				y += 7
			end
		end
		camera(draw_x, draw_y)
	else
		self.index = 0
		self.last = 0
	end
end
function message:draw_below()
	spr(12, self.x, self.y)
end

-- level completion marker and summary
flag = {}
function flag:init()
	self.x += 5
end
function flag:update()
	if not self.show and self.player_here() then
		sfx(55)
		self.show = true
		time_ticking = false
	end
end
function flag:draw()
	spr(16 + frames / 10 % 3, self.x, self.y)
	if self.show then
		camera()
		rectfill(game_w / 2 - 32, 2, game_w / 2 + 32, 31, 0)

		local fruit_text = "x" .. fruit_count
		local fruit_w = print(fruit_text, 0, -1000)
		local fruit_x = flr(game_w / 2 - (9 + fruit_w) / 2)
		spr(20, fruit_x, 6)
		print(fruit_text, fruit_x + 9, 9, 7)

		local time_text = get_time_str()
		local time_w = print(time_text, 0, -1000)
		local time_x = flr(game_w / 2 - time_w / 2)
		rectfill(time_x - 1, 16, time_x + time_w, 22, 0)
		print(time_text, time_x, 17, 7)

		local deaths_text = "deaths:" .. deaths
		local deaths_w = print(deaths_text, 0, -1000)
		print(deaths_text, flr(game_w / 2 - deaths_w / 2), 24, 7)

		camera(draw_x, draw_y)
	end
end
