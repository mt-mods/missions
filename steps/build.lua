
local counter = {} -- playername -> count

missions.register_step({

	type = "simplebuild",
	name = "Place nodes",

	create = function()
		return {count=100}
	end,


	get_status = function(step, stepdata, player)
		local name = player:get_player_name()
		local current_count = counter[name] or 0
		local rest = stepdata.count - (current_count - stepdata.start)
		return "Place " .. rest .. " nodes"
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)
		local formspec = "size[8,8;]" ..
			"label[0,0;Place any nodes]" ..
	
			"field[0,2;8,1;count;Count;" .. stepdata.count ..  "]" ..
			"button_exit[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor, show_mission)
		if fields.count then
			local count = tonumber(fields.count)
			if count and count > 0 then
				stepdata.count = count
			end
		end

		if fields.save then
			show_mission()
		end
	end,

	on_step_enter = function(step, stepdata, player, success, failed)
		local name = player:get_player_name()
		stepdata.start = counter[name] or 0
	end,

	on_step_interval = function(step, stepdata, player, success, failed)
		local name = player:get_player_name()
		local current_count = counter[name] or 0
		if current_count - stepdata.start >= stepdata.count then
			success()
		end
	end,

	on_step_exit = function(step, stepdata, player)
	end


})

minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack)
	if player ~= nil and player:is_player() then
		local name = player:get_player_name()
		local count = counter[name]
		if not count then
			count = 0
		end

		count = count + 1
		counter[name] = count
	end
end)


