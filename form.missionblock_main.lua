
local FORMNAME = "mission_block_main"

missions.form.missionblock_main = function(pos, node, player)

	local meta = minetest.get_meta(pos)

	-- check for migration
	missions.migrate_mission_block(pos, meta)

	local has_override = minetest.check_player_privs(player, "protection_bypass")

	-- check if plain user rightclicks
	if player:get_player_name() ~= owner and not has_override then
		missions.form.missionblock_user(pos, node, player)
		return
	end

	local formspec = "size[8,8;]" ..
		--left
		"label[0,0;Mission block]" ..
		"button_exit[0,1;8,1;configure;Configure]" ..
		"button_exit[0,2;8,1;stepeditor;Step editor]" ..
		"button_exit[0,3;8,1;user;User view]" ..
		"button_exit[0,4;8,1;stats;Statistics]" ..
		"button_exit[0,5;8,1;help;Help]" ..
		"button_exit[0,7;8,1;exit;Exit]"

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

	if fields.stepeditor then
		minetest.after(0.1, function()
			missions.form.missionblock_stepeditor(pos, node, player)
		end)
		return true
	end

	if fields.user then
		minetest.after(0.1, function()
			missions.form.missionblock_user(pos, node, player)
		end)
		return true
	end

	if fields.stats then
		minetest.after(0.1, function()
			missions.form.missionblock_stats(pos, node, player)
		end)
		return true
	end

	if fields.configure then
		minetest.after(0.1, function()
			missions.form.missionblock_config(pos, node, player)
		end)
		return true
	end

	if fields.help then
		minetest.after(0.1, function()
			missions.form.missionblock_help(pos, node, player)
		end)
		return true
	end


end)

