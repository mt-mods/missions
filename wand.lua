
minetest.register_craftitem("missions:wand_position", {
	description = "Mission wand with position",
	inventory_image = "missions_wand_position.png",
	stack_max = 1
})

minetest.register_craftitem("missions:wand_chest", {
	description = "Mission wand with chest-reference",
	inventory_image = "missions_wand_chest.png",
	stack_max = 1
})

minetest.register_craftitem("missions:wand_mission", {
	description = "Mission wand with mission-reference",
	inventory_image = "missions_wand_mission.png",
	stack_max = 1
})


minetest.register_craftitem("missions:wand", {
	description = "Mission wand",
	inventory_image = "missions_wand.png",
	on_use = function(itemstack, player, pointed_thing)
		if pointed_thing and pointed_thing.type == "node" and pointed_thing.under then
			missions.form.wand(pointed_thing.under, player)
		end

		return itemstack
	end
})


-- crafts

minetest.register_craft({
	type = "shapeless",
	output = "missions:wand",
	recipe = {"missions:wand_chest"}
})

minetest.register_craft({
	type = "shapeless",
	output = "missions:wand",
	recipe = {"missions:wand_position"}
})

minetest.register_craft({
	output = "missions:wand 3",
	recipe = {
		{"default:stick", "", "default:obsidian_shard"},
		{"", "default:stick", ""},
		{"default:mese_crystal_fragment", "", "default:stick"}
	}
})