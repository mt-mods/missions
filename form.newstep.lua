
local FORMNAME = "mission_block_newstep"

missions.form.newstep = function(pos, node, player)

	local formspec = "size[8,8;]" ..
		"label[0,0;New step]" ..
		"button_exit[0,1;2,1;walkto;Walk to]"

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

	if fields.walkto then
		local steps = missions.get_steps(pos)
		print(#steps)

		table.insert(steps, {
			type="walkto",
			name="Walk to",
			time=300,
			pos=nil
		})

		missions.set_steps(pos, steps)
		local stepnumber = #steps+1

		minetest.after(0.1, function()
			missions.form.walkto(pos, node, player, stepnumber)
		end)
	end

	print(dump(pos)) --XXX
	print(dump(fields))

end)

