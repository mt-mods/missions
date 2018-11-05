
local FORMNAME = "mission_block_chains"

local count_chain_steps = function(pos, chain)
	return #missions.get_steps(pos, chain)
end

missions.form.missionblock_chains = function(pos, node, player)

	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	local formspec = "size[8,8;]" ..
		"label[0,0;Mission block chains]" ..

		"button[0,1;8,1;beforesteps;Before Steps (" .. count_chain_steps(pos, "beforesteps") .. ")]" ..
		"button[0,2;8,1;mainsteps;Main Steps (" .. count_chain_steps(pos, "steps") .. ")]" ..
		"button[0,3.5;4,1;failsteps;Fail Steps (" .. count_chain_steps(pos, "failsteps") .. ")]" ..
		"button[4,3.5;4,1;successsteps;Success Steps (" .. count_chain_steps(pos, "successsteps") .. ")]" ..
		"button[0,5;8,1;aftersteps;After Steps (" .. count_chain_steps(pos, "aftersteps") .. ")]" ..

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
		missions.form.missionblock_stepeditor(pos, node, player, "steps")
		return true
	end

	if fields.beforesteps then
		missions.form.missionblock_stepeditor(pos, node, player, "beforesteps")
		return true
	end

	if fields.failsteps then
		missions.form.missionblock_stepeditor(pos, node, player, "failsteps")
		return true
	end

	if fields.successsteps then
		missions.form.missionblock_stepeditor(pos, node, player, "successsteps")
		return true
	end

	if fields.aftersteps then
		missions.form.missionblock_stepeditor(pos, node, player, "aftersteps")
		return true
	end

end)

