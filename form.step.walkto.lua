
local FORMNAME = "mission_block_step_walkto"

missions.form.walkto = function(pos, node, player)

	local inv = minetest.get_inventory({type="node", pos=pos})
	inv:set_size("walkto_inv", 1)

	local pos_str = pos.x..","..pos.y..","..pos.z

	local formspec = "size[8,8;]" ..
		"label[0,0;Step: Walk to]" ..
		"list[nodemeta:" .. pos_str .. ";walkto_inv;0,1;1,1;]" ..
		"list[current_player;main;0,2;8,1;]"

	minetest.show_formspec(player:get_player_name(),
		FORMNAME .. ";" .. minetest.pos_to_string(pos),
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

	print(dump(pos)) --XXX
	print(dump(fields))

end)

