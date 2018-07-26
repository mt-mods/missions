
local FORMNAME = "mission_block_newstep"

missions.form.newstep = function(pos, node, player)

	local step_buttons = ""
	local offset = 1


	local list = ""
	for i,spec in ipairs(missions.steps) do

		list = list .. minetest.formspec_escape(spec.name)
		if i < #missions.steps then
			-- not end of list
			list = list .. ","
		end
	end

	local formspec = "size[8,10;]" ..
		"label[0,0;New step]" ..
		"textlist[0,1;8,7;steptype;" .. list .. "]" ..
		"button_exit[0,9;8,1;add;Add]"

	minetest.show_formspec(player:get_player_name(),
		FORMNAME .. ";" .. minetest.pos_to_string(pos),
		formspec
	)

end

local selected_newstep_index = {} -- playername -> index


minetest.register_on_player_receive_fields(function(player, formname, fields)
	local parts = formname:split(";")
	local name = parts[1]
	if name ~= FORMNAME then
		return
	end

	local pos = minetest.string_to_pos(parts[2])
	local node = minetest.get_node(pos)

	if not missions.check_owner(pos, player) then
		return
	end

	if fields.steptype then
		parts = fields.steptype:split(":")
		if parts[1] == "CHG" then
			local selected_step = tonumber(parts[2])
			selected_newstep_index[player:get_player_name()] = selected_step
		end
	end

	if fields.add then
		local index = selected_newstep_index[player:get_player_name()]
		local spec = missions.steps[index]

		-- check privs
		if spec.privs and not minetest.check_player_privs(player:get_player_name(), spec.privs) then
			minetest.chat_send_player(player:get_player_name(), "Missing privs: " .. dump(spec.privs))
			return
		end


		local stepdata = spec.create()
		local step = {
			type = spec.type,
			name = spec.name,
			data = stepdata
		}

		local steps = missions.get_steps(pos)
		table.insert(steps, step)

		missions.set_steps(pos, steps)
		local stepnumber = #steps

		missions.show_step_editor(pos, node, player, stepnumber, step, stepdata)
	end

end)


