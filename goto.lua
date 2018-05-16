

minetest.register_node("missions:goto", {
	description = "Goto mission",
	tiles = {
		"default_gold_block.png",
		"default_gold_block.png",
		"default_gold_block.png^default_obsidian_shard.png^missions_m_overlay.png",
		"default_gold_block.png^default_obsidian_shard.png^missions_m_overlay.png",
		"default_gold_block.png^default_obsidian_shard.png^missions_m_overlay.png",
		"default_gold_block.png^default_obsidian_shard.png^missions_m_overlay.png"
	},
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults()
})