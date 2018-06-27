local has_xp_redo_mod = minetest.get_modpath("xp_redo")

local showif = function(cond, str)
	if cond then
		return str
	else
		return ""
	end
end


local show_formspec = function(pos, meta, player, type)
	local inv = meta:get_inventory()

	local mission_name = meta:get_string("mission_name")
	local mission_description = meta:get_string("mission_description")

	local distance = 0

	local toBookStack = inv:get_stack("to", 1)
	if toBookStack and missions.is_book(toBookStack) then
		local target = minetest.deserialize(toBookStack:get_meta():get_string("text"))
		if target then
			distance = math.floor(vector.distance(pos, target))
		end
	end

	local pos_str = pos.x..","..pos.y..","..pos.z
	local formspec = "size[8,10;]"

	if type == "admin" then
		formspec = formspec ..
			-- col 1
			"field[0,1.5;4,1;mission_name;Mission name;" .. mission_name .. "]" ..
			"button_exit[4,1;2,1;save;Save]" ..
			"button_exit[6,1;2,1;userview;User-view]" ..

			-- col 2
			"label[0,2;Target (" .. distance .. " m)]" ..
			"list[nodemeta:" .. pos_str .. ";to;4,2;1,1;]" ..
			"field[6,2.5;2,1;time;Time (min);" .. meta:get_int("time") .. "]" ..

			-- col 3
			"label[0,3;Reward]" ..
			"list[nodemeta:" .. pos_str .. ";reward;2,3;3,1;]" ..
			showif(has_xp_redo_mod, "field[6,3.5;2,1;rewardxp;XP-Reward;" .. meta:get_int("rewardxp") .. "]") ..

			-- col 4
			"label[0,4;Transport]" ..
			"list[nodemeta:" .. pos_str .. ";transport;2,4;3,1;]" ..
			showif(has_xp_redo_mod, "field[6,4.5;2,1;penaltyxp;XP-Penalty;" .. meta:get_int("penaltyxp") .. "]") ..

			-- col 5
			"field[0,5;8,1;mission_description;Mission description;" .. mission_description .. "]" ..

			-- col 6
			"list[current_player;main;0,6;8,1;]"
	end

	if type == "user" then
		formspec = formspec ..
			-- col 1
			"label[0,1.5;" .. mission_name .. "]" ..
			"button_exit[4,1;4,1;start;Start]" ..

			-- col 2
			"label[0,2;Target (" .. distance .. " m)]" ..
			"label[4,2;Time: " .. meta:get_int("time") .. " min]" ..

			-- col 3
			"label[0,3;Reward]" ..
			"list[nodemeta:" .. pos_str .. ";reward;2,3;3,1;]" ..
			showif(has_xp_redo_mod, "field[6,3.5;2,1;rewardxp;XP-Reward;" .. meta:get_int("rewardxp") .. "]") ..

			-- col 4
			"label[0,4;Transport]" ..
			"list[nodemeta:" .. pos_str .. ";transport;2,4;3,1;]" ..
			showif(has_xp_redo_mod, "field[6,4.5;2,1;penaltyxp;XP-Penalty;" .. meta:get_int("penaltyxp") .. "]") ..

			-- col 5,6,7,8
			"label[0,5;" .. mission_description .. "]"
	end

	minetest.show_formspec(player:get_player_name(), "transportmission;"..minetest.pos_to_string(pos), formspec)

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
		meta:set_string("mission_description", "")

		-- xp stuff
		if has_xp_redo_mod then
			meta:set_int("rewardxp", 10)
			meta:set_int("penaltyxp", 20)
			meta:set_int("entryxp", 0)
		end
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

	end
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
	local parts = formname:split(";")
	local name = parts[1]
	if name ~= "transportmission" then
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
		-- admin
		if fields.save then

			meta:set_string("mission_name", fields.mission_name)
			meta:set_string("mission_description", fields.mission_description)
			meta:set_string("infotext", "Transport-mission: " .. fields.mission_name)

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
		-- user
	end

	if fields.userview then
		show_formspec(pos, meta, player, "user")
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
				minetest.chat_send_player(playername, "to-book malformed")
				return
			end

			mission.target = target

			missions.start_mission(player, mission)

		else
			minetest.chat_send_player(playername, "to-book not available")
		end


	end


end)

