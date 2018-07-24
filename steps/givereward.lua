
local get_inv_name = function(player)
	return "mission_givereward_" .. player:get_player_name()
end

local get_inv = function(player)
	return minetest.get_inventory({type="detached",name=get_inv_name(player)})
end

local hud = {} -- playerName -> {}
local remainingItems = {} -- playerName -> ItemStack

-- setup detached inv
minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	local inv = minetest.create_detached_inventory(get_inv_name(player), {
		allow_put = function(inv, listname, index, stack, player)
			if not inv:is_empty(listname) then
				return 0
			end

			if listname == "target" and stack:get_name() == "missions:wand_chest" then
				return stack:get_count()
			end

			if listname == "main" then
				return stack:get_count()
			end

			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			-- remove from det inv
			inv:remove_item(listname, stack)
			-- give player nothing
			return 0
		end,
		on_put = function(inv, listname, index, stack, player)
			-- copy stack
			local playerInv = player:get_inventory()
			playerInv:add_item("main", stack)
		end,
	})
	inv:set_size("main", 1)
	inv:set_size("target", 1)
end)

missions.register_step({

	type = "givereward",
	name = "Reward (give)",

	privs = { give=true },

	create = function()
		return {stack=""}
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)
		local inv = get_inv(player)
		inv:set_stack("main", 1, ItemStack(stepdata.stack))


		local formspec = "size[8,8;]" ..
			"label[0,0;Reward items (give)]" ..

			"label[0,1;Items]" ..
			"list[detached:" .. get_inv_name(player) .. ";main;2,1;1,1;]" ..

			"list[current_player;main;0,6;8,1;]" ..
			"button_exit[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor, show_mission)

		if fields.save then
			local inv = get_inv(player)
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


