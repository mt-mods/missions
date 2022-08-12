
local HUD_POSITION = {x = missions.hud.posx, y = missions.hud.posy }
local HUD_ALIGNMENT = {x = 1, y = 0}


local hud = {} -- playerName -> {}
local remainingItems = {} -- playerName -> ItemStack: the target item and count, eg, "default:stone 50"
local remainingCount = {} -- playerName -> count: the player put items in chest

local function cleanItemInChest(inv, stackItem, inv_name)
	stackItem:set_count(1)
	local maxRun = 99
	while inv:contains_item(inv_name, stackItem) and maxRun > 0 do
		stackItem:set_count(100*100)
		inv:remove_item(inv_name, stackItem)
		maxRun = maxRun - 1
	end

	--[[
	if inv_name == nil then inv_name = "main" end
	for i = 1, inv:get_size(inv_name) do
		local vStack = inv:get_stack(inv_name, i)
		if vStack:get_name() == stack:get_name() then
			vStack:set_count(0)
			-- inv:set_stack(inv_name, i)
		end
	end
	--]]
end

missions.register_step({

	type = "chestput",
	name = "Put in chest",

	create = function()
		return {stack="", pos=nil, name="", visible=1, resetChest=false, showCount=false}
	end,

	get_status = function(ctx)
		local player = ctx.player
		local stepdata = ctx.step.data

		local count = remainingCount[player:get_player_name()]
		if type(count) == "number" then
			local stack = ItemStack(stepdata.stack)
			if not stepdata.showCount then count = "n" end
			return "Put " .. count .. " x " .. stack:get_name() .. " into the chest"
		else
			return ""
		end
	end,

	validate = function(ctx)
		local meta = minetest.get_meta(ctx.pos)
		local stepdata = ctx.step.data

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

	allow_inv_stack_put = function(listname, index, stack)
		-- allow position wand on pos 1 of main inv
		if listname == "main" then
			if index == 2 and stack:get_name() == "missions:wand_chest" then
				return true
			end

			if index == 1 then
				return true
			end
		end

		return false
	end,

	edit_formspec = function(ctx)
		local stepdata = ctx.step.data
		local pos = ctx.pos
		local resetChest = "false"
		local showCount = "false"
		if stepdata.resetChest then resetChest = "true" end
		if stepdata.showCount then showCount = "true" end

		ctx.inv:set_stack("main", 1, ItemStack(stepdata.stack))

		local name = ""

		if stepdata.pos then
			local distance = vector.distance(ctx.pos, stepdata.pos)
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
			"checkbox[4,-0.2;showCount;Show Count;".. showCount .. "]" ..

			"label[0,1;Items]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;2,1;1,1;0]" ..

			"label[3,1;Target]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;4,1;1,1;1]" ..

			"label[0,2;" .. name .. "]" ..

			"button_exit[0,6.5;8,1;togglevisible;" .. visibleText .. "]" ..

			"list[current_player;main;0,2.5;8,4;]listring[]" ..
			"button[0,7.3;4,1;save;Save]" ..
			"checkbox[4.5,7.3;resetChest;Reset Chest;".. resetChest .. "]"

		return formspec;
	end,

	update = function(ctx)

		local fields = ctx.fields
		local inv = ctx.inv
		local stepdata = ctx.step.data

		if fields.resetChest == "true" then
			stepdata.resetChest = true
		elseif fields.resetChest == "false" then
			stepdata.resetChest = false
		end

		if fields.showCount == "true" then
			stepdata.showCount = true
		elseif fields.showCount == "false" then
			stepdata.showCount = false
		end

		if fields.togglevisible then
			if stepdata.visible == 1 then
				stepdata.visible = 0
			else
				stepdata.visible = 1
			end

			ctx.show_editor()
		end

		if fields.save then
			local stack = inv:get_stack("main", 1)

			if not stack:is_empty() then
				stepdata.stack = stack:to_string()
			end

			stack = inv:get_stack("main", 2)

			if not stack:is_empty() then
				local meta = stack:get_meta()
				local pos = minetest.string_to_pos(meta:get_string("pos"))
				local name = meta:get_string("name")

				stepdata.pos = pos
				stepdata.name = name
			end

			ctx.show_mission()
		end
	end,

	on_step_enter = function(ctx)

		local stepdata = ctx.step.data
		local player = ctx.player
		local playerName = player:get_player_name()

		-- set stack
		remainingItems[playerName] = stepdata.stack
		local stack =ItemStack(stepdata.stack)
		remainingCount[playerName] = stack:get_count()
		if stepdata.resetChest then
			local meta = minetest.get_meta(stepdata.pos)
			local inv = meta:get_inventory()
			local removeStack = ItemStack(stepdata.stack)
			cleanItemInChest(inv, removeStack, "main")
		end

		local hud_data = {}
		hud[playerName] = hud_data;

		hud_data.counter = player:hud_add({
			hud_elem_type = "text",
			position = HUD_POSITION,
			offset = {x = 0,   y = 140},
			text = "",
			alignment = HUD_ALIGNMENT,
			scale = {x = 100, y = 100},
			number = 0x00FF00
		})

		hud_data.image = player:hud_add({
			hud_elem_type = "image",
			position = HUD_POSITION,
			offset = {x = 32,   y = 140},
			text = missions.get_image(stack:get_name()),
			alignment = HUD_ALIGNMENT,
			scale = {x = 0.5, y = 0.5},
		})

		-- set waypoint, if enabled
		if stepdata.visible == 1 then
			hud_data.target = player:hud_add({
				hud_elem_type = "waypoint",
				name = "Chest: " .. stepdata.name,
				text = "m",
				number = 0xFF0000,
				world_pos = stepdata.pos
			})
		end
	end,

	on_step_interval = function(ctx)
		local player = ctx.player
		local playerName = player:get_player_name()
		local stepdata = ctx.step.data

		local count = remainingCount[playerName]
		if type(count) == "number" then
			if count == 0 then
				ctx.on_success()
			end

			local hud_data = hud[player:get_player_name()]
			if not stepdata.showCount then count = "n " end
			player:hud_change(hud_data.counter, "text", count .. "x")
		else
			ctx.on_success()
		end
	end,

	on_step_exit = function(ctx)
		local player = ctx.player
		local playerName = player:get_player_name()

		remainingItems[playerName] = ""
		remainingCount[playerName] = nil
		local hud_data = hud[playerName]

		if hud_data and hud_data.image then
			player:hud_remove(hud_data.image)
		end

		if hud_data and hud_data.counter then
			player:hud_remove(hud_data.counter)
		end

		if hud_data and hud_data.target then
			player:hud_remove(hud_data.target)
		end

		hud[playerName] = nil
	end


})

local intercept_chest = function(name)
	local def = minetest.registered_nodes[name]

	if def ~= nil then
		local delegate_put = def.on_metadata_inventory_put
		local delegate_take = def.on_metadata_inventory_take

		def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
			if player and player:is_player() then
				local playerName = player:get_player_name()
				local remStack = ItemStack(remainingItems[playerName])

				if remStack:get_name() == stack:get_name() then
					local count = remainingCount[playerName] or remStack:get_count()
					count = count - stack:get_count()
					remainingCount[playerName] = count
				end

				--print("Put Stack: " .. stack:get_name())
			end

			--delegate
			delegate_put(pos, listname, index, stack, player)
		end

		def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
			if player and player:is_player() then
				local playerName = player:get_player_name()
				local remStack = ItemStack(remainingItems[playerName])

				if remStack:get_name() == stack:get_name() then
					local count = remainingCount[playerName] or remStack:get_count()
					count = count + stack:get_count()
					remainingCount[playerName] = count
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
-- TODO: technic-chests


