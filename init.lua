
local MP = minetest.get_modpath("missions")

missions = {
	list={} -- playername -> missionObj[]
}

dofile(MP.."/functions.lua")
dofile(MP.."/hud.lua")
dofile(MP.."/missionblock.lua")
dofile(MP.."/missionchest.lua")

print("[OK] Missions")
