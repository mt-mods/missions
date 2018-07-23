
local get_inv_name = function(player)
	return "mission_walkto_" .. player:get_player_name()
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
		end
	})
	inv:set_size("main", 1)
end)

missions.register_step({

	type = "walkto",
	name = "Walk to",

	create = function()
		return {pos=nil, name="", time=300}
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)
		local formspec = "size[8,8;]" ..
			"label[0,0;Walk to (Step #" .. stepnumber .. ")]" ..

			"list[detached:" .. get_inv_name(player) .. ";main;0,1;1,1;]" ..
			"button_exit[1,1;4,1;read;Read position]" ..

			--TODO: escape
			"label[0,2;" .. stepdata.name .. "]" ..

			"list[current_player;main;0,3;8,1;]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor)
		if fields.read then
			local inv = get_inv(player)
			local stack = inv:get_stack("main", 1)

			if not stack:is_empty() then
				local meta = stack:get_meta()
				local pos = minetest.string_to_pos(meta:get_string("pos"))
				local name = meta:get_string("name")

				stepdata.pos = pos
				stepdata.name = name
				--TODO: how to handle used wand: give it back to user?
			end

			show_editor()
		end

		--TODO: timeout,name
	end,

	on_step_enter = function(step, stepdata, player)
		hud[player:get_player_name()] = player:hud_add({
			hud_elem_type = "waypoint",
			name = stepdata.name,
			text = "m",
			number = 0x0000FF,
			world_pos = stepdata.pos
		})
	end,

	on_step_interval = function(step, stepdata, player, success, failed)
		-- TODO: check if player entered position
	end,

	on_step_exit = function(step, stepdata, player)
		local idx = hud[player:get_player_name()]
		if idx then
			player:hud_remove(idx)
			hud[player:get_player_name()] = nil
		end
	end


})


