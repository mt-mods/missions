
local MP = minetest.get_modpath("missions")

missions = {
	list={} -- playername -> missionObj[]
}

dofile(MP.."/cooldown.lua")
dofile(MP.."/functions.lua")
dofile(MP.."/register.lua")
dofile(MP.."/hud.lua")
dofile(MP.."/block.lua")

print("[OK] Missions")
