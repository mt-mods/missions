local has_xp_redo_mod = minetest.get_modpath("xp_redo")

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

-- executor
dofile(MP.."/executor.lua")
dofile(MP.."/executor.hud.lua")

-- step register
dofile(MP.."/register_step.lua")

-- step specs
dofile(MP.."/steps/waypoint.lua")
dofile(MP.."/steps/dig.lua")
dofile(MP.."/steps/build.lua")

if has_xp_redo_mod then
	dofile(MP.."/steps/checkxp.lua")
end


print("[OK] Missions")