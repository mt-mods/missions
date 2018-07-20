local has_xp_redo_mod = minetest.get_modpath("xp_redo")


missions.save_missions = function()
	-- TODO
end

missions.load_missions = function()
	-- TODO
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
			//TODO
		end

		timer = 0
	end
end)

missions.only_owner_can_dig = function(pos, player)
	if not player then
		return false
	end

	local meta = minetest.get_meta(pos)
	local playername = player:get_player_name() or ""
	return meta:get_string("owner") == playername
end



