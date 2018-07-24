
local get_inv_name = function(player)
	return "mission_chestput_" .. player:get_player_name()
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

	type = "chestput",
	name = "Put in chest",

	create = function()
		return {stack="", pos=nil, name="", visible=1}
	end,

	get_status = function(step, stepdata, player)
		local str = remainingItems[player:get_player_name()]
		if str then
			local stack = ItemStack(str)
			--TODO: prettier item name
			return "Put " .. stack:get_count() .. " x " .. stack:get_name() .. " into the chest"
		else
			return ""
		end
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

		if inv:room_for_item("main", removeStack) then
			return {success=true}
		else
			return {
				success=false,
				failed=true,
				msg="Chest has no space for items: " .. stepdata.stack ..
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

		if stepdata.name then
			name = name .. " with name '" .. stepdata.name .. "'"
		end

		local visibleText

		if stepdata.visible == 1 then
			visibleText = "Waypoint: Visible"
		else
			visibleText = "Waypoint: Hidden"
		end

		local formspec = "size[8,8;]" ..
			"label[0,0;Put items in chest]" ..

			"label[0,1;Items]" ..
			"list[detached:" .. get_inv_name(player) .. ";main;2,1;1,1;]" ..

			"label[3,1;Target]" ..
			"list[detached:" .. get_inv_name(player) .. ";target;4,1;1,1;]" ..

			"label[0,2;" .. name .. "]" ..

			"button_exit[0,5;8,1;togglevisible;" .. visibleText .. "]" ..

			"list[current_player;main;0,6;8,1;]" ..
			"button_exit[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor, show_mission)

		if fields.togglevisible then
			if stepdata.visible == 1 then
				stepdata.visible = 0
			else
				stepdata.visible = 1
			end

			show_editor()
		end

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
				local name = meta:get_string("name")

				stepdata.pos = pos
				stepdata.name = name
			end

			show_mission()
		end
	end,

	on_step_enter = function(step, stepdata, player, success, failed)
		-- set stack
		remainingItems[player:get_player_name()] = stepdata.stack

		-- set hud, if enabled
		if stepdata.visible == 1 then
			hud[player:get_player_name()] = player:hud_add({
				hud_elem_type = "waypoint",
				name = "Chest: " .. stepdata.name,
				text = "m",
				number = 0xFF0000,
				world_pos = stepdata.pos
			})
		end
	end,

	on_step_interval = function(step, stepdata, player, success, failed)
		local str = remainingItems[player:get_player_name()]
		if str then
			if ItemStack(str):get_count() == 0 then
				success()
			end
		else
			success()
		end
	end,

	on_step_exit = function(step, stepdata, player)
		remainingItems[player:get_player_name()] = ""
		local idx = hud[player:get_player_name()]
		if idx then
			player:hud_remove(idx)
			hud[player:get_player_name()] = nil
		end
	end


})

local intercept_chest = function(name)
	local def = minetest.registered_nodes[name]

	if def ~= nil then
		local delegate_put = def.on_metadata_inventory_put
		local delegate_take = def.on_metadata_inventory_take

		def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
			if player and player:is_player() then
				local remStack = ItemStack(remainingItems[player:get_player_name()])
				
				if remStack:get_name() == stack:get_name() then
					local count = remStack:get_count() - stack:get_count()
					if count < 0 then count = 0 end

					remStack:set_count(count)
					remainingItems[player:get_player_name()] = remStack:to_string()
				end

				--print("Put Stack: " .. stack:get_name())
			end

			--delegate
			delegate_put(pos, listname, index, stack, player)
		end

		def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
			if player and player:is_player() then
				local remStack = ItemStack(remainingItems[player:get_player_name()])

				if remStack:get_name() == stack:get_name() then
					local count = remStack:get_count() + stack:get_count()
					if count > remStack: get_stack_max() then count = remStack:get_stack_max() end

					remStack:set_count(count)
					remainingItems[player:get_player_name()] = remStack:to_string()
				end
				--print("Take Stack: " .. stack:get_name())
			end

			--delegate
			delegate_take(pos, listname, index, stack, player)
		end
	else
		print("Definition not found: " .. name)
	end
end

local has_more_chests_mod = minetest.get_modpath("more_chests")

intercept_chest("default:chest")
intercept_chest("default:chest_open")

if has_more_chests_mod then
	intercept_chest("more_chests:dropbox")
end
-- TODO: protected, technic-chests


