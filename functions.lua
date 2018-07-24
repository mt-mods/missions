local has_xp_redo_mod = minetest.get_modpath("xp_redo")

missions.check_owner = function(pos, player)
	local meta = minetest.get_meta(pos)
	return player and player:is_player() and player:get_player_name() == meta:get_string("owner")
end

missions.format_time = function(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds - (minutes * 60)
	if secs < 10 then
		return minutes .. ":0" .. secs
	else
		return minutes .. ":" ..secs
	end
	--TODO: hours/days
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



