
local MP = minetest.get_modpath("missions")

missions = {
	form = {}
}

-- forms
dofile(MP.."/form.missionblock.lua")
dofile(MP.."/form.missionblock_user.lua")
dofile(MP.."/form.newstep.lua")
dofile(MP.."/form.wand.lua")


dofile(MP.."/functions.lua")
dofile(MP.."/register.lua")
dofile(MP.."/hud.lua")
dofile(MP.."/block.lua")
dofile(MP.."/wand.lua")


-- step register
dofile(MP.."/register_step.lua")

-- step specs
dofile(MP.."/steps/walkto.lua")


print("[OK] Missions")