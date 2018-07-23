
local FORMNAME = "mission_block_step_walkto"

local get_inv_name = function(player)
	return FORMNAME .. "_" .. player:get_player_name()
end

local get_inv = function(player)
	return minetest.get_inventory({type="detached",name=get_inv_name(player)})
end


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

missions.form.walkto = function(pos, node, player, stepnumber)
	local formspec = "size[8,8;]" ..
		"label[0,0;Walk to (Step #" .. stepnumber .. ")]" ..

		"list[detached:" .. get_inv_name(player) .. ";main;0,1;1,1;]" ..
		"button_exit[1,1;4,1;read;Read position]" ..

		"label[0,2;My label]" ..

		"list[current_player;main;0,3;8,1;]"

	minetest.show_formspec(player:get_player_name(),
		FORMNAME .. ";" .. minetest.pos_to_string(pos) .. ";" .. stepnumber,
		formspec
	)

end



minetest.register_on_player_receive_fields(function(player, formname, fields)
	local parts = formname:split(";")
	local name = parts[1]
	if name ~= FORMNAME then
		return
	end

	local pos = minetest.string_to_pos(parts[2])
	local node = minetest.get_node(pos)
	local stepnumber = tonumber(parts[3])

	if fields.read then
		local inv = get_inv(player)
		local stack = inv:get_stack("main", 1)

		if not stack:is_empty() then
			local meta = stack:get_meta()
			local pos = minetest.string_to_pos(meta:get_string("pos"))
			local name = meta:get_string("name")

			print("Name: " .. name .. " in step: " .. stepnumber)--XXX
			--TODO: how to handle used wand: give it back to user?
		end
	end

	print(dump(pos)) --XXX
	print(dump(fields))

end)

