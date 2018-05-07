
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
		"field[6,2.5;2,1;time;Time (min);" .. meta:get_int("time") .. "]" ..

		-- col 3
		"label[0,3;Reward]" ..
		"list[context;reward;3,3;2,1;]" ..
		"field[6,3.5;2,1;rewardmultiplier;Multiplier;" .. meta:get_int("reward-multi") .. "]" ..

		-- col 4
		"label[0,4;Transport]" ..
		"list[context;transport;3,4;2,1;]" ..
		"field[6,4.5;2,1;transportmultiplier;Multiplier;" .. meta:get_int("transport-multi") .. "]" ..

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
		inv:set_size("from", 1)
		inv:set_size("to", 1)
		inv:set_size("reward", 2)
		inv:set_size("transport", 2)

		meta:set_int("reward-multi", 1)
		meta:set_int("transport-multi", 1)
		meta:set_int("time", 5)

		meta:set_string("infotext", "Unconfigured mission-block")
		update_formspec(meta)
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)

		-- owner
		if player:get_player_name() == meta:get_string("owner") then
			-- TODO: check book moves
			return count
		end

		-- non-owner
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)

		-- owner
		if player:get_player_name() == meta:get_string("owner") then

			local name = stack:get_name()

			if listname == "from" or listname == "to" or listname == "book" then
				if name == "default:book_written" then
					return stack:get_count()
				else
					-- only written books allowed
					return 0
				end
			end

			return stack:get_count()
		end

		-- non-owner
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)

		-- owner
		if player:get_player_name() == meta:get_string("owner") then
			return stack:get_count()
		end

		-- non-owner
		if listname == "book" then
			-- mission books always allowed
			return -1
		end

		-- other items not allowed
		return 0

	end,

	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local name = sender:get_player_name()

		if name == meta:get_string("owner") then
			-- owner
			if fields.save then
				local time = tonumber(fields.time)
				if time ~= nil then meta:set_int("time", time) end

				local rewardMulti = tonumber(fields.rewardmultiplier)
				if rewardMulti~= nil then meta:set_int("reward-multi", rewardMulti) end

				local transportMulti = tonumber(fields.transportmultiplier)
				if transportMulti~= nil then meta:set_int("transport-multi", transportMulti) end
			end
		else
			-- non-owner
		end

		update_formspec(meta)
	end

})