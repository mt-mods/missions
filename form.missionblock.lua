
local FORMNAME = "mission_block_main"

missions.form.missionblock = function(pos, node, player)

	local meta = minetest.get_meta(pos)
	local steps = minetest.deserialize(meta:get_string("steps"))

	print(meta:get_string("steps"))

	local steps_list = "textlist[0,1;5,6;steps;"
	for i,step in pairs(steps) do
		steps_list = i .. ": " .. step.name .. ","
	end
	steps_list = steps_list .. "]";


	local formspec = "size[8,8;]" ..
		"label[0,0;Mission editor]" ..
		"button_exit[6,1;2,1;add;Add]" ..
		"button[6,2;2,1;up;Up]" ..
		"button[6,3;2,1;down;Down]" ..
		"button[6,4;2,1;remove;Remove]" ..
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
	local node = minetest.get_node(pos)

	if fields.add then
		minetest.after(0.1, function()
			missions.form.newstep(pos, node, player)
		end)
	end

	print(dump(pos)) --XXX
	print(dump(fields))

end)

