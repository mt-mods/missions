
minetest.register_node("missions:mission", {
	description = "Mission block",
	tiles = {
		"default_gold_block.png",
		"default_gold_block.png",
		"default_gold_block.png^default_paper.png^missions_m_overlay.png",
		"default_gold_block.png^default_paper.png^missions_m_overlay.png",
		"default_gold_block.png^default_paper.png^missions_m_overlay.png",
		"default_gold_block.png^default_paper.png^missions_m_overlay.png"
	},
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local playername = placer:get_player_name() or ""
		meta:set_string("owner", playername)
	end,

	can_dig = missions.only_owner_can_dig,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		-- TODO
	end,

	on_rightclick = function(pos, node, player)

		local formspec = "size[8,8;]" ..
			"field[0,0.5; 6,1;name;Name;]" ..
			"button_exit[6,0.1; 2,1;save;Save]" ..
			"textlist[0,1.5; 8,6;statements;#ee0000 abc,#00ee00 def,#0000ee ghi;2;true]"

		minetest.show_formspec(player:get_player_name(),
			"mission_block;" .. minetest.pos_to_string(pos),
			formspec
		)

		-- TODO
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local parts = formname:split(";")
	local name = parts[1]
	if name ~= "mission_block" then
		return
	end

	local pos = minetest.string_to_pos(parts[2])


	print(dump(pos))
	print(dump(fields))

end)





