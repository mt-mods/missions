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

	local to_pos = missions.book_to_pos(inv:get_stack("to", 1))

	if to_pos then
		distance = math.floor(vector.distance(pos, to_pos))
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
			"field[6,5.5;2,1;cooldown;Cooldown;" .. meta:get_int("cooldown") .. "]" ..

			-- col 6
			"field[0,6.5;8,1;mission_description;Mission description;" .. mission_description .. "]" ..

			--TODO: entryxp

			-- col 7
			"list[current_player;main;0,7.5;8,1;]"
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
			showif(has_xp_redo_mod, "label[6,3.5;XP-Reward: " .. meta:get_int("rewardxp") .. "]") ..

			-- col 4
			"label[0,4;Transport]" ..
			"list[nodemeta:" .. pos_str .. ";transport;2,4;3,1;]" ..
			showif(has_xp_redo_mod, "label[6,4.5;XP-Penalty: " .. meta:get_int("penaltyxp") .. "]") ..

			--TODO: entryxp

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
		local playername = placer:get_player_name() or ""
		meta:set_string("owner", playername)
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		inv:set_size("to", 1)
		inv:set_size("reward", 3)
		inv:set_size("transport", 3)
		meta:set_int("time", 300)
		meta:set_int("cooldown", 0)
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
		local has_give = minetest.check_player_privs(player, {give=true})

		-- owner
		if player:get_player_name() == meta:get_string("owner") then

			local name = stack:get_name()
			local inv = minetest.get_meta(pos):get_inventory()

			if listname == "to" and name == "default:book_written" then
				inv:set_stack(listname, index, stack)
			end

			if listname == "reward" or listname == "transport" then
				inv:set_stack(listname, index, stack)
			end

		end

		-- non-owner
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)

		-- owner
		if player:get_player_name() == meta:get_string("owner") then
			local inv = minetest.get_meta(pos):get_inventory()
			local fake_stack = inv:get_stack(listname, index)
			fake_stack:take_item(stack:get_count())
			inv:set_stack(listname, index, fake_stack)
			return 0
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
	local has_give_xp_priv = minetest.check_player_privs(player, {givexp=true})
	local owner = meta:get_string("owner")

	if playername == owner then
		-- admin
		if fields.save then

			meta:set_string("mission_name", fields.mission_name)
			meta:set_string("mission_description", fields.mission_description)
			meta:set_string("infotext", "Transport-mission: " .. fields.mission_name .. " (" .. owner .. ")")

			local time = tonumber(fields.time)
			if time ~= nil then meta:set_int("time", time) end

			local cooldown = tonumber(fields.cooldown)
			if cooldown ~= nil then meta:set_int("cooldown", cooldown) end

			local rewardxp = tonumber(fields.rewardxp)
			if rewardxp~= nil and has_give_xp_priv then meta:set_int("rewardxp", rewardxp) end

			local penaltyxp = tonumber(fields.penaltyxp)
			if penaltyxp~= nil and has_give_xp_priv then meta:set_int("penaltyxp", penaltyxp) end

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
		mission.cooldown = meta:get_int("cooldown")

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

		local to_pos = missions.book_to_pos(inv:get_stack("to", 1))

		if to_pos then
			-- TODO: validate on setup
			-- to and mission books available
			mission.target = to_pos

			missions.start_mission(player, mission)

		else
			minetest.chat_send_player(playername, "to-book not available/valid")
		end


	end


end)

