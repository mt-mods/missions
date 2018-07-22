
local FORMNAME = "mission_wand_name"

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

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local parts = formname:split(";")
	local name = parts[1]
	if name ~= FORMNAME then
		return
	end

	local pos = minetest.string_to_pos(parts[2])

	if not fields.name then
		return
	end

	local inv = player:get_inventory()
	local stack = ItemStack("missions:wand_position")
	local meta = stack:get_meta()
	

	local posStr = minetest.pos_to_string(pos)
	meta:set_string("pos", posStr)
	meta:set_string("name", fields.name)
	meta:set_string("description", "Mission wand to position: " .. posStr .. " with name: '" .. fields.name .. "'")

	if inv:contains_item("main", "missions:wand") and inv:room_for_item("main", stack) then
		inv:remove_item("main", "missions:wand")
		inv:add_item("main", stack)
	end

end)

minetest.register_craftitem("missions:wand", {
	description = "Mission wand",
	inventory_image = "missions_wand.png",
	on_use = function(itemstack, player, pointed_thing)
		if pointed_thing and pointed_thing.type == "node" and pointed_thing.under then
			local formspec = "size[8,1;]" ..
				"field[0,0.5;6,1;name;Name;]" ..
				"button_exit[6,0.1;2,1;save;Save]";

			minetest.show_formspec(player:get_player_name(),
				FORMNAME .. ";" .. minetest.pos_to_string(pointed_thing.under),
				formspec
			)
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