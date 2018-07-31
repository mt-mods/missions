local has_mobs_mod = minetest.get_modpath("mobs")

if has_mobs_mod then
	minetest.register_privilege("missions_mobs", {
		description = "Allows the creation of mission steps with mobs"
	});
end