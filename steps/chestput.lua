

missions.register_step({

	type = "chestput",
	name = "Put in chest",

	create = function()
		return {count=1, name="default:cobble"}
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)
		local formspec = "size[8,8;]" ..
			"label[0,0;Put items in chest]" ..
	
			"button_exit[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor, show_mission)
		--TODO

		if fields.save then
			show_mission()
		end
	end,

	on_step_enter = function(step, stepdata, player, success, failed)
		--TODO
	end,

	on_step_interval = function(step, stepdata, player, success, failed)
		--TODO
	end,

	on_step_exit = function(step, stepdata, player)
		--TODO
	end


})

local intercept_chest = function(name)
	local def = minetest.registered_nodes[name]

	if def ~= nil then
		local delegate_put = def.on_metadata_inventory_put
		local delegate_take = def.on_metadata_inventory_take

		def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
			print("Put Stack: " .. stack:get_name())

			--delegate
			delegate_put(pos, listname, index, stack, player)
		end

		def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
			print("Take Stack: " .. stack:get_name())

			--delegate
			delegate_take(pos, listname, index, stack, player)
		end
	else
		print("Definition not found: " .. name)
	end
end

intercept_chest("default:chest")
intercept_chest("default:chest_open")
-- TODO: protected, technic-chests


