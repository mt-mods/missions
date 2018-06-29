


minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack)
	if player and player:is_player() and newnode and newnode.name then

		local playername = player:get_player_name()
		local playermissions = missions.list[playername]
		if playermissions ~= nil then
			for j,mission in pairs(playermissions) do
				if mission.type == "build" then
					local stack = ItemStack(newnode.name)
					stack:set_count(1)

					if missions.update_mission(player, mission, stack) > 0 then
						return
					end
				end
			end
		end
	end
end)

-- dig mission
minetest.register_on_dignode(function(pos, oldnode, digger)
	if digger ~= nil and digger:is_player() then
		local playername = digger:get_player_name()
		local playermissions = missions.list[playername]
		if playermissions ~= nil then
			for j,mission in pairs(playermissions) do
				if mission.type == "dig" then
					local stack = ItemStack(oldnode.name)
					stack:set_count(1)

					if missions.update_mission(digger, mission, stack) > 0 then
						return
					end
				end
			end
		end
	end
end)


-- craft mission
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if player and player:is_player() then
		local playername = player:get_player_name()
		local playermissions = missions.list[playername]
		if playermissions ~= nil then
			for j,mission in pairs(playermissions) do
				if mission.type == "craft" then
					local stack = ItemStack(itemstack:to_string())
					if missions.update_mission(player, mission, stack) > 0 then
						return
					end
				end
			end
		end
	end
end)



