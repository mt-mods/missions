

missions.is_book = function(stack)
	return stack:get_count() == 1 and stack:get_name() == "default:book_written"
end

missions.save_missions = function()
	-- TODO
end

missions.load_missions = function()
	-- TODO
end

missions.start_mission = function(player, mission)
	print(dump(mission)) -- XXX

	local playername = player:get_player_name()
	local playermissions = missions.list[playername]
	if playermissions == nil then playermissions = {} end

	for i,m in pairs(playermissions) do
		if m.title == mission.title then
			minetest.chat_send_player(playername, "Mission already running: " .. mission.title)
			return
		end
	end

	table.insert(playermissions, mission)

	missions.list[playername] = playermissions
	missions.save_missions()
end

missions.remove_mission = function(player, mission)
	local playername = player:get_player_name()
	local playermissions = missions.list[playername]
	if playermissions == nil then playermissions = {} end

	for i,m in pairs(playermissions) do
		if m.title == mission.title then
			table.remove(playermissions, i)
			return
		end
	end
end


local update_player_mission = function(player, mission, remaining)
	if remaining <= 0 then
		-- mission timed-out
		missions.hud_remove_mission(player, mission)
		missions.remove_mission(player, mission)
		minetest.chat_send_player(player:get_player_name(), "Mission timed out!: " .. mission.title)
	end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
		local now = os.time(os.date("!*t"))
		local players = minetest.get_connected_players()
		for i,player in pairs(players) do
			local playername = player:get_player_name()
			local playermissions = missions.list[playername]
			if playermissions ~= nil then
				for j,mission in pairs(playermissions) do
					local remaining = mission.time - (now - mission.start)

					update_player_mission(player, mission, remaining)
				end
			end
			missions.hud_update(player, playermissions)
		end

		timer = 0
	end
end)

