
missions.register_step({

	type = "limitedtries",
	name = "Limited tries",

	create = function()
		return {maxcount=1, counts={}} -- "xy"=1
	end,

	edit_formspec = function(ctx)
		local stepdata = ctx.step.data
		local stepnumber = ctx.stepnumber

		local formspec = "size[8,8;]" ..
			"label[0,0;Limited tries (Step #" .. stepnumber .. ")]" ..

			"field[0,2;8,1;maxcount;Count;" .. stepdata.maxcount ..  "]" ..
			"button[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(ctx)
		local fields = ctx.fields
		local stepdata = ctx.step.data

		if fields.maxcount then
			local maxcount = tonumber(fields.maxcount)
			if maxcount and maxcount > 0 then
				stepdata.maxcount = maxcount
			end
		end

		if fields.save then
			ctx.show_mission()
		end
	end,

	on_step_enter = function(ctx)
		local player = ctx.player
		local playername = player:get_player_name()
		local stepdata = ctx.step.data
		local tries = stepdata.counts[playername] or 0

		stepdata.counts[playername] = tries + 1

		if tries < stepdata.maxcount then
			ctx.on_success()
		else
			ctx.on_failed("Number of tries exceeded!")
		end
	end

})
