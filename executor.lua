
local MISSION_ATTRIBUTE_NAME = "currentmission"
local CURRENT_MISSION_SPEC_VERSION = 1

local playermissions = {}

--persistence stuff

minetest.register_on_joinplayer(function(player)
	local missionStr = player:get_attribute(MISSION_ATTRIBUTE_NAME)

	local mission = nil
	if missionStr then
		mission = minetest.deserialize(missionStr)
	end

	if mission and mission.version == CURRENT_MISSION_SPEC_VERSION then
		-- only load if compatible with current spec
		local step = mission.steps[mission.currentstep]
		
		-- reset init flag
		step.initialized = false

		-- store in variable
		playermissions[player:get_player_name()] = mission
	end
end)

minetest.register_on_leaveplayer(function(player)
	playermissions[player:get_player_name()] = nil
end)

local get_current_mission = function(player)
	return playermissions[player:get_player_name()]
end

local persist_mission = function(player, mission)
	player:set_attribute(MISSION_ATTRIBUTE_NAME, minetest.serialize(mission))
end


local set_current_mission = function(player, mission)
	playermissions[player:get_player_name()] = mission
end

-- start a mission
missions.start = function(pos, player)
	local mission = get_current_mission(player)
	local playername = player:get_player_name()

	if mission then
		minetest.chat_send_player(playername, "A Mission is already running: '" .. mission.name .. "'")
		return
	end

	local steps = missions.get_steps(pos)
	if #steps == 0 then
		minetest.chat_send_player(playername, "Mission has no steps!")
		return
	end

	local meta = minetest.get_meta(pos)

	mission = {
		version = CURRENT_MISSION_SPEC_VERSION,
		steps = steps,
		currentstep = 1,
		start = os.time(os.date("!*t")),
		time = meta:get_int("time") or 300,
		name = meta:get_string("name") or "<no name>",
		description = meta:get_string("description") or ""
	}

	set_current_mission(player, mission)
end

-- update the mission
local update_mission = function(mission, player)

	local now = os.time(os.date("!*t"))
	local remainingTime = mission.time - (now - mission.start)
	local playername = player:get_player_name()
	local step = mission.steps[mission.currentstep]

	if not step then
		-- no more steps
		minetest.chat_send_player(playername, "Mission completed: '" .. mission.name .. "'")
		set_current_mission(player, nil)
		return
	end

	local spec = missions.get_step_spec_by_type(step.type)

	missions.hud_update(player, mission)

	local success = false
	local failed = false
	
	local on_success = function()
		success = true
	end

	local on_failed = function(msg)
		failed = true
		minetest.chat_send_player(playername, "Mission failed: " .. msg)
		set_current_mission(player, nil)
		missions.hud_update_status(player, "")
		if spec.on_step_exit then
			spec.on_step_exit(step, step.data, player)
		end
	end

	if remainingTime <= 0 then
		on_failed("timed out")
		return
	end


	if not step.initialized then
		if spec.on_step_enter then
			spec.on_step_enter(step, step.data, player, on_success, on_failed)
		end
		step.initialized = true
	end

	if failed then
		return
	end

	if not success then
		if spec.on_step_interval then
			spec.on_step_interval(step, step.data, player, on_success, on_failed)
		end
	end

	if failed then
		return
	end


	if spec.get_status then
		local status = spec.get_status(step, step.data, player)
		missions.hud_update_status(player, status)
	else
		missions.hud_update_status(player, "")
	end


	if success then
		mission.currentstep = mission.currentstep + 1
		if spec.on_step_exit then
			spec.on_step_exit(step, step.data, player)
		end
		return
	end
end

-- mission persist job
local persistTimer = 0
minetest.register_globalstep(function(dtime)
	persistTimer = persistTimer + dtime;
	if persistTimer >= 5 then
		local players = minetest.get_connected_players()
		for i,player in ipairs(players) do
			local mission = get_current_mission(player)
			persist_mission(player, mission)
		end

		persistTimer = 0
	end
end)

-- mission update step
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 0.5 then
		local players = minetest.get_connected_players()
		for i,player in ipairs(players) do
			local playername = player:get_player_name()
			local mission = get_current_mission(player)

			if mission then
				update_mission(mission, player)
			else
				missions.hud_update(player, nil)
			end
		end

		timer = 0
	end
end)