

missions.is_book = function(stack)
	return stack:get_count() == 1 and stack:get_name() == "default:book_written"
end

missions.pos_equal = function(pos1, pos2)
	return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
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


-- returns count of items moved to target (if any)
missions.update_mission = function(player, mission, stack)

	minetest.log("action", "[missions] " .. player:get_player_name() .. " updates transport items: " .. stack:to_string())
	local count = 0

	for i,targetStackStr in pairs(mission.transport.list) do
		local targetStack = ItemStack(targetStackStr)

		if targetStack:get_name() == stack:get_name() then
			-- same type
			local takenStack = targetStack:take_item(stack:get_count())
			count = count + takenStack:get_count()

			-- save remaining stack
			mission.transport.list[i] = targetStack:to_string()
		end
	end

	return count
end


local check_player_mission = function(player, mission, remaining)
	if remaining <= 0 then
		-- mission timed-out
		missions.hud_remove_mission(player, mission)
		missions.remove_mission(player, mission)
		minetest.chat_send_player(player:get_player_name(), "Mission timed out!: " .. mission.title)
		minetest.log("action", "[missions] " .. player:get_player_name() .. " -- mission timed out: " .. mission.title)

		-- TODO: penalty (xp?)
	end

	local openCount = 0
	for i,itemStr in pairs(mission.transport.list) do
		-- check if items placed
		local stack = ItemStack(itemStr)
		if not stack:is_empty() then
			openCount = openCount + 1
		end
	end

	if openCount == 0 then
		-- mission finished
		-- XXX
		print(dump(mission))


		missions.hud_remove_mission(player, mission)
		missions.remove_mission(player, mission)
		minetest.chat_send_player(player:get_player_name(), "Mission finished: " .. mission.title)
		minetest.log("action", "[missions] " .. player:get_player_name() .. " -- mission finished: " .. mission.title)

		-- TODO: proper finish animation
		-- TODO: xp reward

		local inv = player:get_inventory()
		for i,stackStr in pairs(mission.reward.list) do
			-- reward player
			local stack = ItemStack(stackStr)
			inv:add_item("main", stack)
		end
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

					check_player_mission(player, mission, remaining)
				end
			end
			missions.hud_update(player, playermissions)
		end

		timer = 0
	end
end)

