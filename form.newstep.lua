
local FORMNAME = "mission_block_newstep"

missions.form.newstep = function(pos, node, player)

	local step_buttons = ""
	local offset = 1

	for i,spec in ipairs(missions.steps) do
		step_buttons = step_buttons ..
			"button_exit[0," .. i-1+offset .. ";4,1;" .. spec.type .. ";" .. spec.name .. "]"
	end

	local formspec = "size[8,8;]" ..
		"label[0,0;New step]" ..
		step_buttons

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
	local node = minetest.get_node(pos)

	if not missions.check_owner(pos, player) then
		return
	end

	for i,spec in ipairs(missions.steps) do
		if fields[spec.type] then

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

			minetest.after(0.1, function()
				missions.show_step_editor(pos, node, player, stepnumber, step, stepdata)
			end)
		end
	end

end)


