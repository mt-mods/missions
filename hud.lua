
local HUD_POSITION = {x = 0.5, y = 0.2}
local HUD_ALIGNMENT = {x = 1, y = 0}

local hud = {} -- playerName -> {}


-- returns the image (itam, node, tool) or ""
local get_image = function(name)
	-- minetest.registered_items[name].inventory_image
	-- minetest.registered_tools[name].inventory_image
	-- minetest.registered_nodes["default:stone"].tiles[1]


	if name == nil then
		return ""
	end

	local node = minetest.registered_nodes[name]
	if node ~= nil and node.tiles ~= nil and table.getn(node.tiles) == 1 then
		return minetest.inventorycube(node.tiles[1],node.tiles[1],node.tiles[1])
	end

	local item = minetest.registered_items[name]
	if item ~= nil and item.inventory_image ~= nil then
		return item.inventory_image
	end

	local tool = minetest.registered_tools[name]
	if tool ~= nil and tool.inventory_image ~= nil then
		return tool.inventory_image
	end

	-- none found
	return ""
end

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

	data.transport1 = player:hud_add({
		hud_elem_type = "image",
		position = HUD_POSITION,
		offset = {x = 0,   y = 110},
		text = "",
		alignment = HUD_ALIGNMENT,
		scale = {x = 1, y = 1},
	})

	data.transport2 = player:hud_add({
		hud_elem_type = "image",
		position = HUD_POSITION,
		offset = {x = 80,   y = 110},
		text = "",
		alignment = HUD_ALIGNMENT,
		scale = {x = 1, y = 1},
	})

	data.transport3 = player:hud_add({
		hud_elem_type = "image",
		position = HUD_POSITION,
		offset = {x = 160,   y = 110},
		text = "",
		alignment = HUD_ALIGNMENT,
		scale = {x = 1, y = 1},
	})

	hud[playername] = data
end)

minetest.register_on_leaveplayer(function(player)
	local playername = player:get_player_name()
	hud[playername] = nil
end)

local format_time = function(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds - (minutes * 60)
	if secs < 10 then
		return minutes .. ":0" .. secs
	else
		return minutes .. ":" ..secs
	end
end

missions.hud_remove_mission = function(player, mission)
	-- remove waypoints from elapsed mission
	if mission.hud ~= nil and mission.hud.source ~= nil then
		player:hud_remove(mission.hud.source)
	end

	if mission.hud ~= nil and mission.hud.target ~= nil then
		player:hud_remove(mission.hud.target)
	end
end

missions.hud_update = function(player, playermissions)
	local playername = player:get_player_name()

	local now = os.time(os.date("!*t"))
	local data = hud[playername]
	local topMission = nil

	if data ~= nil and playermissions ~= nil then
		for i,mission in pairs(playermissions) do

			if mission.hud == nil then


				if mission.type == "transport" then
					-- add waypoint markers if new mission
					mission.hud = {}
					mission.hud.target = player:hud_add({
						hud_elem_type = "waypoint",
						name = mission.target.title .. "(Destination)",
						text = "m",
						number = 0x0000FF,
						world_pos = {x=mission.target.x, y=mission.target.y, z=mission.target.z}
					})

				end
			end


			-- top mission check
			if topMission == nil then
				topMission = mission
			else
				local remainingTime = mission.time - (now - mission.start)
				local topRemainingTime = topMission.time - (now - topMission.start)

				if remainingTime < topRemainingTime then
					topMission = mission
				end
			end

		end
	end

	if topMission ~= nil then
		-- show the first mission to time out
		local remainingTime = topMission.time - (now - topMission.start)
		player:hud_change(data.title, "text", "Missions: (1/" .. table.getn(playermissions) .. ")")
		player:hud_change(data.mission, "text", topMission.name .. " (" .. topMission.type .. ")")
		player:hud_change(data.time, "text", "" .. format_time(remainingTime))

		if remainingTime > 60 then
			player:hud_change(data.time, "number", 0x00FF00)
			player:hud_change(data.mission, "number", 0x00FF00)
		else
			player:hud_change(data.time, "number", 0xFF0000)
			player:hud_change(data.mission, "number", 0xFF0000)
		end

		if topMission.type == "transport" then

			-- TODO dynamic code
			if topMission.transport.list[1] ~= nil then
				local img = get_image(ItemStack(topMission.transport.list[1]):get_name());
				player:hud_change(data.transport1, "text", img)
			end

			if topMission.transport.list[2] ~= nil then
				local img = get_image(ItemStack(topMission.transport.list[2]):get_name());
				player:hud_change(data.transport2, "text", img)
			end

			if topMission.transport.list[3] ~= nil then
				local img = get_image(ItemStack(topMission.transport.list[3]):get_name());
				player:hud_change(data.transport3, "text", img)
			end
		end

	else
		-- no missions running
		player:hud_change(data.title, "text", "")
		player:hud_change(data.mission, "text", "")
		player:hud_change(data.time, "text", "")
		player:hud_change(data.transport1, "text", "")
		player:hud_change(data.transport2, "text", "")
		player:hud_change(data.transport3, "text", "")
	end
	
end




