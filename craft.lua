

minetest.register_node("missions:craft", {
	description = "Craft mission",
	tiles = {
		"default_gold_block.png",
		"default_gold_block.png",
		"default_gold_block.png^default_paper.png^missions_m_overlay.png",
		"default_gold_block.png^default_paper.png^missions_m_overlay.png",
		"default_gold_block.png^default_paper.png^missions_m_overlay.png",
		"default_gold_block.png^default_paper.png^missions_m_overlay.png"
	},
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults()
})