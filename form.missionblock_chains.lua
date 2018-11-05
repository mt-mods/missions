
local FORMNAME = "mission_block_chains"

missions.form.missionblock_chains = function(pos, node, player)

	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	local formspec = "size[8,8;]" ..
		"label[0,0;Mission block chains]" ..

		"button[0,1;8,1;beforesteps;Before Steps]" ..
		"button[0,2;8,1;mainsteps;Main Steps]" ..
		"button[0,3.5;4,1;failsteps;Fail Steps]" ..
		"button[4,3.5;4,1;successsteps;Success Steps]" ..
		"button[0,5;8,1;aftersteps;After Steps]" ..

		"button_exit[0,7;8,1;exit;Exit]" ..
		missions.FORMBG

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
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)

	if not missions.check_owner(pos, player) then
		return
	end

	if fields.mainsteps then
		missions.form.missionblock_stepeditor(pos, node, player)
		return true
	end

end)

