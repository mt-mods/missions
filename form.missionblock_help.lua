
local FORMNAME = "mission_block_help"

missions.form.missionblock_help = function(pos, node, player)

	local formspec = "size[8,8;]" ..
		--left
		"label[0,0;Mission block]" ..
		"button_exit[0,7;8,1;exit;Exit]"

	minetest.show_formspec(player:get_player_name(),
		FORMNAME .. ";" .. minetest.pos_to_string(pos),
		formspec
	)

end



