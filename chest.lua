
local showif = function(cond, str)
	if cond then
		return str
	else
		return ""
	end
end

local show_formspec = function(pos, meta, player, type)

	local pos_str = pos.x..","..pos.y..","..pos.z
	local formspec = "size[8,9;]"

	formspec = formspec ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"list[nodemeta:" .. pos_str .. ";main;0,0.3;8,3;]" ..

		"field[1,4;4,1;title;Title;" .. meta:get_string("title") .. "]" ..
		"button[5,3.5;2,1;save;Save]" ..
		showif(type == "admin", "list[nodemeta:" .. pos_str .. ";ref;7,3.3;1,1;]") ..

		"list[current_player;main;0,4.85;8,1;]" ..
		"list[current_player;main;0,6.08;8,3;8]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,4.85)

	minetest.show_formspec(player:get_player_name(), "missionchest;"..minetest.pos_to_string(pos), formspec)

end


local create_book_ref = function(pos)
	local meta = minetest.get_meta(pos)
	local title = meta:get_string("title")

	local bookStack = missions.pos_to_book(pos, title)

	local inv = meta:get_inventory()

	-- remove old book
	inv:remove_item("ref", bookStack)

	if inv:room_for_item("ref", bookStack) then
		-- put written book back
		inv:add_item("ref", bookStack)
	end

end

minetest.register_node("missions:missionchest", {
	description = "Mission chest",
	tiles = {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png^missions_m_overlay.png",
		"default_chest_side.png^missions_m_overlay.png",
		"default_chest_front.png^missions_m_overlay.png",
		"default_chest_side.png^missions_m_overlay.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	sound_open = "default_chest_open",
	sound_close = "default_chest_close",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},

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
		create_book_ref(pos)
	end,

	on_rightclick = function(pos, node, clicker)

		if not clicker or not clicker:is_player() then
			return
		end

		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local playername = clicker:get_player_name()

		if playername == owner then
			show_formspec(pos, meta, clicker, "admin")
		else
			show_formspec(pos, meta, clicker, "user")
		end
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		-- disallow book-to-inventory move
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)

		-- owner
		if player:get_player_name() == meta:get_string("owner") then
			return stack:get_count()
		end

		-- not allowed
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		-- check mission
		local playermissions = missions.list[player:get_player_name()]

		if playermissions == nil then
			-- without missions
			return stack:get_count()
		end

		for i,mission in pairs(playermissions) do
			if mission.target and mission.type == "transport" and missions.pos_equal(pos, mission.target) then
				-- mission target matches
				local movedItems = missions.update_mission(player, mission, stack)
				-- with mission
				return movedItems
			end
		end

		-- without mission
		return stack:get_count()
	end

})


minetest.register_on_player_receive_fields(function(player, formname, fields)
	local parts = formname:split(";")
	local name = parts[1]
	if name ~= "missionchest" then
		return
	end

	local pos = minetest.string_to_pos(parts[2])
	if not pos then
		return
	end

	local meta = minetest.get_meta(pos)
	local playername = player:get_player_name()
	local owner = meta:get_string("owner")

	if playername == owner then
		if fields.save and playername == owner then
			meta:set_string("title", fields.title)
			meta:set_string("infotext", "Mission chest (" .. fields.title .. ")")
		end

		create_book_ref(pos)
	end
end)

