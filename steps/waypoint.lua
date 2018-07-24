
local get_inv_name = function(player)
	return "mission_waypoint_" .. player:get_player_name()
end

local get_inv = function(player)
	return minetest.get_inventory({type="detached",name=get_inv_name(player)})
end

local hud = {} -- playerName -> {}

-- setup detached inv for wand placement
minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	local inv = minetest.create_detached_inventory(get_inv_name(player), {
		allow_put = function(inv, listname, index, stack, player)
			if stack:get_name() == "missions:wand_position" then
				return 1
			end

			return 0
		end,
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

	type = "waypoint",
	name = "Waypoint",

	create = function()
		return {pos=nil, name="", radius=3, visible=1, description=""}
	end,

	get_status = function(step, stepdata, player)
		return stepdata.description
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)

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
			"label[0,0;Walk to (Step #" .. stepnumber .. ")]" ..

			"list[detached:" .. get_inv_name(player) .. ";main;0,1;1,1;]" ..

			--TODO: escape
			"label[0,2;" .. name .. "]" ..

			"field[0,3;8,1;description;Description;" .. stepdata.description .. "]" ..

			"field[0,4;4,1;radius;Radius;" .. stepdata.radius .. "]" ..
			"button_exit[0,5;8,1;togglevisible;" .. visibleText .. "]" ..

			"list[current_player;main;0,6;8,1;]" ..
			"button_exit[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor, show_mission)

		if fields.radius then
			local radius = tonumber(fields.radius)
			if radius and radius > 0 then
				stepdata.radius = radius
			end
		end

		if fields.togglevisible then
			if stepdata.visible == 1 then
				stepdata.visible = 0
			else
				stepdata.visible = 1
			end

			show_editor()
		end

		if fields.description then
			stepdata.description = fields.description
		end

		if fields.save then
			local inv = get_inv(player)
			local stack = inv:get_stack("main", 1)

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
		if stepdata.visible == 1 then
			hud[player:get_player_name()] = player:hud_add({
				hud_elem_type = "waypoint",
				name = "Mission-waypoint: " .. stepdata.name,
				text = "m",
				number = 0xFF0000,
				world_pos = stepdata.pos
			})
		end
	end,

	on_step_interval = function(step, stepdata, player, success, failed)
		local pos = player:get_pos()

		local distance = vector.distance(player:get_pos(), stepdata.pos)
		if distance < stepdata.radius then
			success()
		end
	end,

	on_step_exit = function(step, stepdata, player)
		local idx = hud[player:get_player_name()]
		if idx then
			player:hud_remove(idx)
			hud[player:get_player_name()] = nil
		end
	end


})


