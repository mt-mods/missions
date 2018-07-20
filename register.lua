


minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack)
	if player and player:is_player() and newnode and newnode.name then

		local playername = player:get_player_name()
		//TODO
	end
end)

-- dig mission
minetest.register_on_dignode(function(pos, oldnode, digger)
	if digger ~= nil and digger:is_player() then
		local playername = digger:get_player_name()
		//TODO
	end
end)


-- craft mission
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if player and player:is_player() then
		local playername = player:get_player_name()
		//TODO
	end
end)



