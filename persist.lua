
-- mission persist job
local persistTimer = 0
minetest.register_globalstep(function(dtime)
	persistTimer = persistTimer + dtime;
	if persistTimer >= 15 then
		local players = minetest.get_connected_players()
		for i,player in ipairs(players) do
			local mission = missions.get_current_mission(player)
			missions.persist_mission(player, mission)
		end

		persistTimer = 0
	end
end)