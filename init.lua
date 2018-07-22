
local MP = minetest.get_modpath("missions")

missions = {
	form = {}
}

-- forms
dofile(MP.."/form.missionblock.lua")
dofile(MP.."/form.newstep.lua")
dofile(MP.."/form.step.walkto.lua")
dofile(MP.."/form.wand.lua")

dofile(MP.."/functions.lua")
dofile(MP.."/register.lua")
dofile(MP.."/hud.lua")
dofile(MP.."/block.lua")
dofile(MP.."/wand.lua")

print("[OK] Missions")