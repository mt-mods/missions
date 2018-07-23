local has_xp_redo_mod = minetest.get_modpath("xp_redo")

-- running player missions
missions.save_missions = function()
	-- TODO
end

missions.load_missions = function()
	-- TODO
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


-- timeout check
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
		local now = os.time(os.date("!*t"))
		local players = minetest.get_connected_players()
		for i,player in pairs(players) do
			local playername = player:get_player_name()
			-- TODO
		end

		timer = 0
	end
end)

-- node register helper
missions.only_owner_can_dig = function(pos, player)
	if not player then
		return false
	end

	--TODO: check protection_bypass

	local meta = minetest.get_meta(pos)
	local playername = player:get_player_name() or ""
	return meta:get_string("owner") == playername
end



