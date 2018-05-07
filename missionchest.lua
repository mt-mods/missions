

local update_formspec = function(meta)
	local formspec = 
		"size[8,9]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"list[context;main;0,0.3;8,3;]" ..

		"field[1,4;4,1;title;Title;" .. meta:get_string("title") .. "]" ..
		"button[5,3.5;2,1;save;Save]" ..
		"list[context;ref;7,3.3;1,1;]" ..

		"list[current_player;main;0,4.85;8,1;]" ..
		"list[current_player;main;0,6.08;8,3;8]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,4.85)

	meta:set_string("formspec", formspec)
end

local create_book_ref = function(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	local new_stack = ItemStack("default:book_written")
	local stackMeta = new_stack:get_meta()

	-- remove old book
	inv:remove_item("ref", new_stack)


	local data = {}
	local title = meta:get_string("title")

	data.owner = "missions"
	data.title = "Mission chest (" .. title .. ")"
	data.description = data.title
	data.text = minetest.serialize({x=pos.x, y=pos.y, z=pos.z, title=title})
	data.page = 1
	data.page_max = 1

	new_stack:get_meta():from_table({ fields = data })

	if inv:room_for_item("ref", new_stack) then
		-- put written book back
		inv:add_item("ref", new_stack)
	end

end

minetest.register_node("missions:missionchest", {
	description = "Mission chest",
	tiles = {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"missionchest_front.png",
		"default_chest_side.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	sound_open = "default_chest_open",
	sound_close = "default_chest_close",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},

	drop = "missions:missionchest",

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		inv:set_size("main", 8*3)
		inv:set_size("ref", 1)

		meta:set_string("title", "My chest")
		meta:set_string("infotext", "Mission chest")
		update_formspec(meta)
		create_book_ref(pos)
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		create_book_ref(pos)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)

		if fields.save then
			meta:set_string("title", fields.title)
		end

		update_formspec(meta)
		create_book_ref(pos)
	end,

	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end

})

