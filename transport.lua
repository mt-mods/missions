local has_xp_redo_mod = minetest.get_modpath("xp_redo")

local update_formspec = function(meta)
	local inv = meta:get_inventory()

	local mission_name = meta:get_string("mission_name")
	meta:set_string("infotext", "Transport-mission: " .. mission_name)

	local xp_str = function(str)
		if has_xp_redo_mod then
			return str
		else
			return ""
		end
	end


	meta:set_string("formspec", "size[8,10;]" ..
		-- col 1
		"field[0,1.5;4,1;mission_name;Mission name;" .. mission_name .. "]" ..
		"button_exit[4,1;2,1;save;Save]" ..
		"button_exit[6,1;2,1;start;Start]" ..

		-- col 2
		"label[2,2;To]" ..
		"list[context;to;3,2;1,1;]" ..
		"field[6,2.5;2,1;time;Time (min);" .. meta:get_int("time") .. "]" ..

		-- col 3
		"label[0,3;Reward]" ..
		"list[context;reward;2,3;3,1;]" ..
		xp_str("field[6,3.5;2,1;rewardxp;XP-Reward;" .. meta:get_int("rewardxp") .. "]") ..

		-- col 4
		"label[0,4;Transport]" ..
		"list[context;transport;2,4;3,1;]" ..
		xp_str("field[6,4.5;2,1;penaltyxp;XP-Penalty;" .. meta:get_int("penaltyxp") .. "]") ..

		-- col 5,6,7,8
		"list[current_player;main;0,5;8,4;]")
end


minetest.register_node("missions:transport", {
	description = "Transport mission",
	tiles = {
		"default_gold_block.png",
		"default_gold_block.png",
		"default_gold_block.png^carts_rail_straight.png^missions_m_overlay.png",
		"default_gold_block.png^carts_rail_straight.png^missions_m_overlay.png",
		"default_gold_block.png^carts_rail_straight.png^missions_m_overlay.png",
		"default_gold_block.png^carts_rail_straight.png^missions_m_overlay.png"
	},
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		inv:set_size("to", 1)
		inv:set_size("reward", 3)
		inv:set_size("transport", 3)
		meta:set_int("time", 300)
		meta:set_string("mission_name", "My mission")

		-- xp stuff
		if has_xp_redo_mod then
			meta:set_int("rewardxp", 10)
			meta:set_int("penaltyxp", 20)
			meta:set_int("entryxp", 0)
		end


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

		-- not allowed
		return 0

	end,

	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local name = sender:get_player_name()

		if name == meta:get_string("owner") then
			-- owner
			if fields.save then

				local name = fields.mission_name
				meta:set_string("mission_name", fields.mission_name)

				local time = tonumber(fields.time)
				if time ~= nil then meta:set_int("time", time) end

				local rewardxp = tonumber(fields.rewardxp)
				if rewardxp~= nil then meta:set_int("rewardxp", rewardxp) end

				local penaltyxp = tonumber(fields.penaltyxp)
				if penaltyxp~= nil then meta:set_int("penaltyxp", penaltyxp) end

				local entryxp = tonumber(fields.entryxp)
				if entryxp~= nil then meta:set_int("entryxp", entryxp) end

			end
		else
			-- non-owner
		end

		if fields.start then
			local inv = meta:get_inventory()

			local mission = {};
			mission.name = meta:get_string("mission_name")
			mission.type = "transport"
			mission.time = meta:get_int("time")

			if has_xp_redo_mod then
				mission.xp = {
					reward = meta:get_int("rewardxp"),
					penalty = meta:get_int("penaltyxp")
				}
			end

			local reward = {}
			reward.list = {}
			local i=1
			while i<=inv:get_size("reward") do
				local stack = inv:get_stack("reward", i)
				if stack:get_count() > 0 then
					table.insert(reward.list, stack:to_string())
				end
				i = i + 1
			end
			mission.reward = reward;

			local context = {}
			context.list = {}
			i = 1
			while i<=inv:get_size("transport") do
				local stack = inv:get_stack("transport", i)
				if stack:get_count() > 0 then
					table.insert(context.list, stack:to_string())
				end
				i = i + 1
			end

			mission.context = context

			local toBookStack = inv:get_stack("to", 1)

			if missions.is_book(toBookStack) then
				-- to and mission books available

				local target = minetest.deserialize(toBookStack:get_meta():get_string("text"))
				if target == nil then
					minetest.chat_send_player(sender:get_player_name(), "to-book malformed")
					return
				end

				mission.target = target

				missions.start_mission(sender, mission)

			else
				minetest.chat_send_player(sender:get_player_name(), "to-book not available")
			end


		end

		update_formspec(meta)
	end

})

