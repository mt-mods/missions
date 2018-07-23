
local HUD_POSITION = {x = 0.5, y = 0.2}
local HUD_ALIGNMENT = {x = 1, y = 0}

local hud = {} -- playerName -> {}

minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()

	local data = {}

	data.title = player:hud_add({
		hud_elem_type = "text",
		position = HUD_POSITION,
		offset = {x = 0,   y = 0},
		text = "",
		alignment = HUD_ALIGNMENT,
		scale = {x = 100, y = 100},
		number = 0xFFFFFF
	})

	data.mission = player:hud_add({
		hud_elem_type = "text",
		position = HUD_POSITION,
		offset = {x = 0,   y = 35},
		text = "",
		alignment = HUD_ALIGNMENT,
		scale = {x = 100, y = 100},
		number = 0x00FF00
	})

	data.time = player:hud_add({
		hud_elem_type = "text",
		position = HUD_POSITION,
		offset = {x = 0,   y = 70},
		text = "",
		alignment = HUD_ALIGNMENT,
		scale = {x = 100, y = 100},
		number = 0x00FF00
	})

	hud[playername] = data
end)

missions.hud_update = function(player, mission, remainingTime)
	local playername = player:get_player_name()
	local data = hud[playername]

	if not data then
		return
	end

	if mission then
		player:hud_change(data.title, "text", "Mission: " .. mission.name)
		player:hud_change(data.mission, "text", "")
		player:hud_change(data.time, "text", "" .. missions.format_time(remainingTime))

		if remainingTime > 60 then
			player:hud_change(data.time, "number", 0x00FF00)
			player:hud_change(data.mission, "number", 0x00FF00)
		else
			player:hud_change(data.time, "number", 0xFF0000)
			player:hud_change(data.mission, "number", 0xFF0000)
		end
	else
		player:hud_change(data.title, "text", "")
		player:hud_change(data.mission, "text", "")
		player:hud_change(data.time, "text", "")
	end
end

minetest.register_on_leaveplayer(function(player)
	local playername = player:get_player_name()
	hud[playername] = nil
end)
