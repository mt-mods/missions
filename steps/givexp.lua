
missions.register_step({

	type = "givexp",
	name = "Give XP",

	privs = {givexp=true},

	create = function()
		return {xp=100}
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)
		local formspec = "size[8,8;]" ..
			"label[0,0;Give XP (Step #" .. stepnumber .. ")]" ..
	
			"field[0,2;8,1;xp;XP;" .. stepdata.xp ..  "]" ..
			"button_exit[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor, show_mission)
		if fields.xp then
			local xp = tonumber(fields.xp)
			if xp and xp > 0 then
				stepdata.xp = xp
			end
		end

		if fields.save then
			show_mission()
		end
	end,

	on_step_enter = function(step, stepdata, player, success, failed)
		xp_redo.add_xp(player:get_player_name(), stepdata.xp)
		success()
	end

})


