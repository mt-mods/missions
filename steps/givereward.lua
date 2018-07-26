

missions.register_step({

	type = "givereward",
	name = "Reward (give)",

	privs = { give=true },

	create = function()
		return {stack=""}
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata, inv)
		inv:set_stack("main", 1, ItemStack(stepdata.stack))


		local formspec = "size[8,8;]" ..
			"label[0,0;Reward items (give)]" ..

			"label[0,1;Items]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;2,1;1,1;0]" ..

			"list[current_player;main;0,6;8,1;]" ..
			"button_exit[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor, show_mission, inv)

		if fields.save then
			local stack = inv:get_stack("main", 1)

			if not stack:is_empty() then
				stepdata.stack = stack:to_string()
			end

			show_mission()
		end
	end,

	on_step_enter = function(step, stepdata, player, success, failed)
		local player_inv = player:get_inventory()
		player_inv:add_item("main", ItemStack(stepdata.stack))
		success()
	end

})


