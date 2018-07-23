
local MISSION_ATTRIBUTE_NAME = "currentmission"

local playermissions = {}

--TODO: load missions from persistent store

local get_current_mission = function(player)
	-- load current mission from memory
	return playermissions[player:get_player_name()]
end

local set_current_mission = function(player, mission)
	--TODO: persistence
	-- player:set_attribute(MISSION_ATTRIBUTE_NAME, minetest.serialize(mission))
	playermissions[player:get_player_name()] = mission
end

missions.start = function(pos, player)
	local mission = get_current_mission(player)
	local playername = player:get_player_name()

	if mission then
		minetest.chat_send_player(playername, "A Mission is already running: '" .. mission.name .. "'")
		return
	end

	local meta = minetest.get_meta(pos)

	mission = {
		steps = missions.get_steps(pos),
		start = os.time(os.date("!*t")),
		time = meta:get_int("time") or 300,
		name = meta:get_string("name") or "<no name>",
		description = meta:get_string("description") or ""
	}

	set_current_mission(player, mission)
end



local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
		local now = os.time(os.date("!*t"))
		local players = minetest.get_connected_players()
		for i,player in pairs(players) do
			local playername = player:get_player_name()
			local mission = get_current_mission(player)

			if mission then
				local remainingTime = mission.time - (now - mission.start)

				missions.hud_update(player, mission, remainingTime)
			end
			-- TODO
		end

		timer = 0
	end
end)