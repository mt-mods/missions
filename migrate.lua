
missions.migrate_mission_block = function(pos, meta)
	local inv = meta:get_inventory()

	if inv:get_size("main") ~= 8 then
		minetest.log("info", "[missions] Migrated mission-block inventory (v1) at pos: " .. minetest.pos_to_string(pos))
		inv:set_size("main", 8)
	end
end