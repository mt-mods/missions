
missions.migrate_mission_block = function(pos, meta)
	local inv = meta:get_inventory()

	if inv:get_size("main") ~= 8 then
		minetest.log("info", "[missions] Migrated mission-block inventory (v1) at pos: " .. minetest.pos_to_string(pos))
		inv:set_size("main", 8)
	end

	if meta:get_int("successcount") == nil then
		meta:set_int("successcount", 0)
	end

	if meta:get_int("failcount") == nil then
		meta:set_int("failcount", 0)
	end

end