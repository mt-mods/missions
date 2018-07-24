
local markers = {} -- playername -> boolean

local FORMNAME = "mission_block_step_message"

missions.register_step({

	type = "message",
	name = "Show message",

	create = function()
		return {title="", message=""}
	end,

	edit_formspec = function(pos, node, player, stepnumber, step, stepdata)
		local formspec = "size[8,8;]" ..
			"label[0,0;Show a message]" ..
	
			"field[0,1;8,1;title;Title;" .. stepdata.title ..  "]" ..
			"textarea[0,2;8,4;message;Message;" .. stepdata.message ..  "]" ..
			"button_exit[0,7;8,1;save;Save]"

		return formspec;
	end,

	update = function(fields, player, step, stepdata, show_editor, show_mission)
		if fields.title then
			stepdata.title = fields.title
		end

		if fields.message then
			stepdata.message = fields.message
		end

	end,

	on_step_enter = function(step, stepdata, player, success, failed)
		markers[player:get_player_name()] = false

		local formspec = "size[8,8;]" ..
			"label[0,0;" .. stepdata.title .. "]" ..
			"label[0,2;" .. stepdata.message .. "]" ..
			"button_exit[5.5,1;2,1;ok;OK]"

		minetest.show_formspec(player:get_player_name(), FORMNAME, formspec)
	end,

	on_step_interval = function(step, stepdata, player, success, failed)
		if markers[player:get_player_name()] then
			success()
		end
	end,

	on_step_exit = function(step, stepdata, player)
		markers[player:get_player_name()] = false
	end


})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	markers[player:get_player_name()] = true
end)





