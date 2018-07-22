
local FORMNAME = "mission_block_step_walkto"

local get_inv_name = function(player)
	return "missionwalkto" .. player:get_player_name()
end

local get_inv = function(player)
	local inv = minetest.get_inventory({type="detached", name=get_inv_name(player)})

	if not inv then
		inv = minetest.create_detached_inventory(get_inv_name(player))
	end

	return inv
end

minetest.create_detached_inventory("test")

missions.form.walkto = function(pos, node, player)

	local inv = get_inv(player)
	--inv:set_size("main", 1)

	local formspec = "size[8,8;]" ..
		"label[0,0;Step Walk to]" ..
		--"list[detached;" .. get_inv_name(player) .. ";0,1;1,1;]" ..
		"list[detached;test;0,1;1,1;]" ..
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

