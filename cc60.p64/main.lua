-- 60fps celeste classic
-- originally off evercore and evetron but i think i've diverged a LOT
-- made by lucidneon

vid(3)
game_w, game_h = get_display():attribs()

include("constants.lua")
include("util.lua")
include("initialization.lua")
include("update.lua")
include("draw.lua")
include("player.lua")
include("objects.lua")
include("levels.lua")
include("metadata.lua")
