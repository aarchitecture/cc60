--[[pod_format="raw",created="2026-05-05 08:53:48",modified="2026-05-05 08:53:52",revision=1]]
-- [globals]

objects = {}
by_type = {}
solids = {}
semis = {}
draw_back = {}
draw_front = {}
got_fruit = {}
level = nil

freeze = 0
delay_restart = 0
music_timer = 0
ui_timer = -99
pause_player = false

cam = {
	x = 0,
	y = 0,
	draw_x = 0,
	draw_y = 0,
	spdx = 0,
	spdy = 0,
	target = nil,
}