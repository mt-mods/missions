
missions.register_step({

	type = "checkxp",
	name = "Check XP",

	create = function()
		return {xp=100}
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)
		local formspec = "size[8,8;]" ..
			"label[0,0;XP Check (Step #" .. stepnumber .. ")]" ..
	
			"field[0,2;8,1;xp;XP Threshold;" .. stepdata.xp ..  "]" ..
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
		if xp_redo.get_xp(player:get_player_name()) > stepdata.xp then
			success()
		else
			failed("Not enough xp, " .. stepdata.xp .. " needed!")
		end
	end

})


