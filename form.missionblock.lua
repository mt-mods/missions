
local FORMNAME = "mission_block_main"

missions.form.missionblock = function(pos, node, player)

	local meta = minetest.get_meta(pos)
	local selected_step = meta:get_int("selected_step")

	print(meta:get_string("steps")) --XXX

	local steps = missions.get_steps(pos)

	-- steps list
	local steps_list = "textlist[0,1;5,6;steps;"
	for i,step in ipairs(steps) do
		--TODO: escape
		steps_list = steps_list .. i .. ": " .. step.name .. ","
	end
	steps_list = steps_list .. ";" .. selected_step .. "]";


	local formspec = "size[8,8;]" ..
		"label[0,0;Mission editor]" ..
		"button_exit[6,1;2,1;add;Add]" ..
		"button_exit[6,2;2,1;edit;Edit]" ..
		"button[6,3;2,1;up;Up]" ..
		"button[6,4;2,1;down;Down]" ..
		"button_exit[6,5;2,1;remove;Remove]" ..
		steps_list

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
			missions.show_step_editor(pos, node, player, stepnumber, step, stepdata)
		end
	end

	if fields.up then
		--TODO
	end

	if fields.down then
		--TODO
	end

	if fields.steps then
		parts = fields.steps:split(":")
		if parts[1] == "CHG" then
			local selected_step = tonumber(parts[2])
			meta:set_int("selected_step", selected_step)
		end
	end

end)

