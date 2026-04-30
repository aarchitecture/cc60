-- [update loop]

function step_clock()
	frames += 1
	if time_ticking then
		ms = flr(frames * 1000 / 60)
		seconds += frames \ 60
		minutes += seconds \ 60
		seconds %= 60
	end
	frames %= 60
end

function step_music()
	if music_timer > 0 then
		music_timer -= 1
		if music_timer <= 0 then
			music(10, 0, 7)
		end
	end
end

function step_restart()
	if delay_restart > 0 then
		cam_spdx, cam_spdy = 0, 0
		delay_restart -= 1
		if delay_restart == 0 then
			load_level(lvl_id)
		end
	end
end

function clamp_clamped_object(obj)
	if obj.clamps then
		local clamped = obj.x
		if lvl_exit ~= "left" then
			clamped = max(-1, clamped)
		end
		if lvl_exit ~= "right" then
			clamped = min(lvl_pw - 7, clamped)
		end

		if obj.x ~= clamped then
			obj.x = clamped
			obj.spd.x = 0
		end

		if lvl_exit ~= "up" and obj.y < -1 then
			obj.y = -1
			obj.spd.y = 0
		end
	end
end

function step_objects()
	foreach(objects, function(obj)
		if obj.spd.x ~= 0 or obj.spd.y ~= 0 or obj.rem.x ~= 0 or obj.rem.y ~= 0 then
			obj.move(obj.spd.x, obj.spd.y, 0)
		end
		obj:update()
		clamp_clamped_object(obj)
	end)
end

function step_camera()
	if cam_target then
		move_camera(cam_target)
	end
end

function step_title()
	if is_title() then
		if start_game then
			start_game_flash -= 1
			if start_game_flash <= title_flash_end then
				begin_game()
			end
		elseif btn(4) or btn(5) then
			music(-1)
			start_game_flash, start_game = title_flash_start, true
			sfx(38)
		end
	end
end

function _update()
	step_clock()
	step_music()

	if freeze > 0 then
		freeze -= 1
		return
	end

	step_restart()
	step_objects()
	step_camera()
	step_title()
end
