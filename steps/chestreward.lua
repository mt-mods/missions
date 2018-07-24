
local get_inv_name = function(player)
	return "mission_chestreward_" .. player:get_player_name()
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

	type = "chestreward",
	name = "Reward from chest",

	create = function()
		return {stack="", pos=nil}
	end,

	validate = function(pos, step, stepdata)
		local meta = minetest.get_meta(stepdata.pos)
		local inv = meta:get_inventory()

		local removeStack = ItemStack(stepdata.stack)

		if stepdata.pos == nil then
			return {
				success=false,
				failed=true,
				msg="No position defined"
			}
		end

		if inv:contains_item("main", removeStack) then
			return {success=true}
		else
			return {
				success=false,
				failed=true,
				msg="Chest does not contain the items: " .. stepdata.stack ..
					" chest-location: " .. stepdata.pos.x .. "/" .. stepdata.pos.y .. "/" .. stepdata.pos.z
			}
		end
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)
		local inv = get_inv(player)
		inv:set_stack("main", 1, ItemStack(stepdata.stack))

		local name = ""

		if stepdata.pos then
			local distance = vector.distance(pos, stepdata.pos)
			name = name .. "Position(" .. stepdata.pos.x .. "/" .. 
				stepdata.pos.y .. "/" .. stepdata.pos.z ..") " ..
				"Distance: " .. math.floor(distance) .. " m"
		end

		local formspec = "size[8,8;]" ..
			"label[0,0;Put items in chest]" ..

			"label[0,1;Items]" ..
			"list[detached:" .. get_inv_name(player) .. ";main;2,1;1,1;]" ..

			"label[3,1;Target]" ..
			"list[detached:" .. get_inv_name(player) .. ";target;4,1;1,1;]" ..

			"label[0,2;" .. name .. "]" ..

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

			stack = inv:get_stack("target", 1)

			if not stack:is_empty() then
				local meta = stack:get_meta()
				local pos = minetest.string_to_pos(meta:get_string("pos"))

				stepdata.pos = pos
			end

			show_mission()
		end
	end,

	on_step_enter = function(step, stepdata, player, success, failed)
		local meta = minetest.get_meta(stepdata.pos)
		local inv = meta:get_inventory()

		local removeStack = ItemStack(stepdata.stack)

		if inv:contains_item("main", removeStack) then
			removeStack = inv:remove_item("main", removeStack)
			local player_inv = player:get_inventory()
			player_inv:add_item("main", removeStack)
			success()
		else
			failed("Items not available in chest: " .. stepdata.stack)
		end

	end

})


