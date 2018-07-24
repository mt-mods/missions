
local FORMNAME = "mission_block_main"

missions.form.missionblock = function(pos, node, player)

	local meta = minetest.get_meta(pos)
	local selected_step = meta:get_int("selected_step")
	local name = meta:get_string("name")
	local time = meta:get_string("time")
	local owner = meta:get_string("owner")
	local description = meta:get_string("description")
	local has_override = minetest.check_player_privs(player, "protection_bypass")

	-- check if plain user rightclicks
	if player:get_player_name() ~= owner and not has_override then
		missions.form.missionblock_user(pos, node, player)
		return
	end

	local steps = missions.get_steps(pos)

	-- steps list
	local steps_list = "textlist[0,1;5,6;steps;"
	for i,step in ipairs(steps) do
		--TODO: escape
		steps_list = steps_list .. i .. ": " .. step.name .. ","
	end
	steps_list = steps_list .. ";" .. selected_step .. "]";


	local formspec = "size[16,8;]" ..
		--left
		"label[0,0;Mission editor]" ..
		"button_exit[5.5,1;2,1;add;Add]" ..
		"button_exit[5.5,2;2,1;edit;Edit]" ..
		"button_exit[5.5,3;2,1;up;Up]" ..
		"button_exit[5.5,4;2,1;down;Down]" ..
		"button_exit[5.5,5;2,1;remove;Remove]" ..
		"button_exit[5.5,6;2,1;user;User]" ..
		steps_list .. 

		--right
		"field[8,1;8,1;name;Name;" .. name ..  "]" ..
		"field[8,2;8,1;time;Time (seconds);" .. time ..  "]" ..
		"textarea[8,3;8,5;description;Description;" .. description .. "]" ..
		"button_exit[0,7;16,1;save;Save and validate]"

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

	-- TODO: priv/player check

	local pos = minetest.string_to_pos(parts[2])
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)

	if fields.add then
		minetest.after(0.1, function()
			missions.form.newstep(pos, node, player)
		end)
	end

	if fields.remove then
		local steps = missions.get_steps(pos)
		local selected_step = meta:get_int("selected_step")
		table.remove(steps, selected_step)
		missions.set_steps(pos, steps)

		minetest.after(0.1, function()
			missions.form.missionblock(pos, node, player)
		end)
	end

	if fields.edit then
		local stepnumber = meta:get_int("selected_step")
		local steps = missions.get_steps(pos)

		local step = steps[stepnumber]

		if step then
			local stepdata = step.data
			minetest.after(0.1, function()
				missions.show_step_editor(pos, node, player, stepnumber, step, stepdata)
			end)
		end
	end

	if fields.name then
		meta:set_string("name", fields.name)
	end

	if fields.time then
		meta:set_string("time", fields.time)
	end

	if fields.description then
		meta:set_string("description", fields.description)
	end

	if fields.up then
		local steps = missions.get_steps(pos)
		local selected_step = meta:get_int("selected_step")
		if selected_step > 1 then
			local tmp = steps[selected_step-1]
			steps[selected_step-1] = steps[selected_step]
			steps[selected_step] = tmp
			missions.set_steps(pos, steps)
			meta:set_int("selected_step", selected_step - 1)
		end

		minetest.after(0.1, function()
			missions.form.missionblock(pos, node, player)
		end)
	end

	if fields.down then
		local steps = missions.get_steps(pos)
		local selected_step = meta:get_int("selected_step")
		if selected_step < #steps then
			local tmp = steps[selected_step+1]
			steps[selected_step+1] = steps[selected_step]
			steps[selected_step] = tmp
			missions.set_steps(pos, steps)
			meta:set_int("selected_step", selected_step + 1)
		end

		minetest.after(0.1, function()
			missions.form.missionblock(pos, node, player)
		end)
	end

	if fields.user then
		minetest.after(0.1, function()
			missions.form.missionblock_user(pos, node, player)
		end)
	end

	if fields.steps then
		parts = fields.steps:split(":")
		if parts[1] == "CHG" then
			local selected_step = tonumber(parts[2])
			meta:set_int("selected_step", selected_step)
		end
	end

	if fields.save then
		local result = missions.validate_mission(pos, player)
		if result.success then
			minetest.chat_send_player(player:get_player_name(), "Mission valid")
		else
			minetest.chat_send_player(player:get_player_name(), "Mission invalid: " .. result.msg)
		end
	end

end)

