
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
		meta:set_string("steps", minetest.serialize({}))
	end,

	on_rightclick = missions.form.missionblock
})




