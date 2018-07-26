
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
		meta:set_int("selected_step", 1)
		meta:set_int("time", 300)
		meta:set_string("name", "")
		meta:set_string("description", "")

		local inv = meta:get_inventory()
		inv:set_size("main", 8)
	end,

	can_dig = missions.only_owner_can_dig,

	on_construct = function(pos)
		missions.set_steps(pos, {})
	end,

	on_rightclick = missions.form.missionblock
})




minetest.register_craft({
	output = "missions:mission",
	recipe = {
		{"missions:wand", "", "missions:wand"},
		{"", "default:goldblock", ""},
		{"", "default:paper", ""}
	}
})