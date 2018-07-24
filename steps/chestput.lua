
local get_inv_name = function(player)
	return "mission_chestput_" .. player:get_player_name()
end

local get_inv = function(player)
	return minetest.get_inventory({type="detached",name=get_inv_name(player)})
end


-- setup detached inv
minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	local inv = minetest.create_detached_inventory(get_inv_name(player), {
		on_put = function(inv, listname, index, stack, player)
			-- copy stack
			local playerInv = player:get_inventory()
			playerInv:add_item("main", stack)
		end,
		allow_take = function(inv, listname, index, stack, player)
			-- remove from det inv
			inv:remove_item("main", stack)
			-- give player nothing
			return 0
		end
	})
	inv:set_size("main", 1)
end)

missions.register_step({

	type = "chestput",
	name = "Put in chest",

	create = function()
		return {count=1, name="default:cobble"}
	end,

	validate = function(pos, node, player, step, stepdata)
		-- TODO
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)
		--TODO: populate inv

		local formspec = "size[8,8;]" ..
			"label[0,0;Put items in chest]" ..
			"list[detached:" .. get_inv_name(player) .. ";main;0,1;1,1;]" ..
			--"button_exit[1,1;4,1;read;Read items]" ..

			"list[current_player;main;0,6;8,1;]" ..
			"button_exit[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor, show_mission)
		--TODO

		if fields.read then
		end

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


