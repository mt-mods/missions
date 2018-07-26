local has_xp_redo_mod = minetest.get_modpath("xp_redo")

missions.check_owner = function(pos, player)
	local meta = minetest.get_meta(pos)
	return player and player:is_player() and player:get_player_name() == meta:get_string("owner")
end

local SECONDS_IN_DAY = 3600*24
local SECONDS_IN_HOUR = 3600
local SECONDS_IN_MINUTE = 60

missions.get_owner_from_pos = function(pos)
	local meta = minetest.get_meta(pos)
	return meta:get_string("owner")
end

missions.format_time = function(seconds)
	local str = ""


	if seconds >= SECONDS_IN_DAY then
		local days = math.floor(seconds / SECONDS_IN_DAY)
		str = str .. days .. " d "
		seconds = seconds - (days * SECONDS_IN_DAY)
	end

	if seconds >= SECONDS_IN_HOUR then
		local hours = math.floor(seconds / SECONDS_IN_HOUR)
		str = str .. hours .. " h "
		seconds = seconds - (hours * SECONDS_IN_HOUR)
	end

	if seconds >= SECONDS_IN_MINUTE then
		local minutes = math.floor(seconds / SECONDS_IN_MINUTE)
		str = str .. minutes .. " min "
		seconds = seconds - (minutes * SECONDS_IN_MINUTE)
	end

	str = str .. seconds .. " s"

	return str
end

-- mission steps setter/getter
missions.get_steps = function(pos)
	local meta = minetest.get_meta(pos)
	local steps = minetest.deserialize(meta:get_string("steps"))

	return steps
end

missions.set_steps = function(pos, steps)
	local meta = minetest.get_meta(pos)
	meta:set_string("steps", minetest.serialize(steps))
end

missions.get_selected_step = function(pos)
	local step = missions.get_steps(pos)
	local meta = minetest.get_meta(pos)

	local selected_step = meta:get_int("selected_step")
	return step[selected_step]		
end


-- node register helper
missions.only_owner_can_dig = function(pos, player)
	if not player then
		return false
	end

	local has_override = minetest.check_player_privs(player, "protection_bypass")

	local meta = minetest.get_meta(pos)
	local playername = player:get_player_name() or ""
	return meta:get_string("owner") == playername or has_override
end


-- returns the image (item, node, tool) or ""
missions.get_image = function(name)
	-- minetest.registered_items[name].inventory_image
	-- minetest.registered_tools[name].inventory_image
	-- minetest.registered_nodes["default:stone"].tiles[1]
	-- TODO: look at drawer code

	if name == nil then
		return ""
	end

	local item = minetest.registered_items[name]
	if item ~= nil and item.inventory_image ~= nil then
		return item.inventory_image
	end

	local tool = minetest.registered_tools[name]
	if tool ~= nil and tool.inventory_image ~= nil then
		return tool.inventory_image
	end

	local node = minetest.registered_nodes[name]
	if node ~= nil and node.tiles ~= nil and table.getn(node.tiles) == 1 then
		return minetest.inventorycube(node.tiles[1],node.tiles[1],node.tiles[1])
	end

	-- none found
	return ""
end


