
local FORMNAME = "mission_block_main"

missions.form.missionblock = function(pos, node, player)

	local meta = minetest.get_meta(pos)
	local selected_step = meta:get_int("selected_step")
	local name = meta:get_string("name")
	local owner = meta:get_string("owner")
	local description = meta:get_string("description")

	-- TODO: user-view entry

	print(meta:get_string("steps")) --XXX

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
		"button[5.5,3;2,1;up;Up]" ..
		"button[5.5,4;2,1;down;Down]" ..
		"button_exit[5.5,5;2,1;remove;Remove]" ..
		"button_exit[5.5,6;2,1;user;User]" ..
		steps_list .. 

		--right
		"field[8,1;8,1;name;Name;" .. name ..  "]" ..
		"textarea[8,2;8,6;description;Description;" .. description .. "]" ..
		"button_exit[0,7;16,1;save;Save]"

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
			missions.show_step_editor(pos, node, player, stepnumber, step, stepdata)
		end
	end

	if fields.name then
		meta:set_string("name", fields.name)
	end

	if fields.description then
		meta:set_string("description", fields.description)
	end

	if fields.up then
		--TODO
	end

	if fields.down then
		--TODO
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

end)

