
local update_formspec = function(meta)
	meta:set_string("formspec", "size[8,10;]" ..
		-- col 1
		"label[0,1;Mission book]" ..
		"list[context;book;3,1;1,1;]" ..
		"button_exit[6,1;2,1;save;Save]" ..

		-- col 2
		"label[0,2;From]" ..
		"list[context;book;1,2;1,1;]" ..
		"label[2,2;To]" ..
		"list[context;book;3,2;1,1;]" ..
		"field[6,2.5;2,1;time;Time (min);5]" ..

		-- col 3
		"label[0,3;Reward]" ..
		"list[context;reward;3,3;2,1;]" ..
		"field[6,3.5;2,1;multiplier;Multiplier;1]" ..

		-- col 4
		"label[0,4;Transport]" ..
		"list[context;transport;3,4;2,1;]" ..
		"field[6,4.5;2,1;multiplier;Multiplier;1]" ..

		-- col 5,6,7,8
		"list[current_player;main;0,5;8,4;]")
end

minetest.register_node("missions:missionblock", {
	description = "Mission block",
	tiles = {"missionblock.png"},
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "missions:missionblock",
	sounds = default.node_sound_glass_defaults(),

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		inv:set_size("book", 1)
		inv:set_size("reward", 2) -- TODO: multiplier
		inv:set_size("transport", 2) -- TODO: multiplier

		meta:set_string("infotext", "Unconfigured mission-block")
		update_formspec(meta)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		update_formspec(meta)
	end

})