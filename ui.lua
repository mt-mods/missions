


unified_inventory.set_inventory_formspec(player, "craft")


unified_inventory.register_page("missions", {
	get_formspec = function(player)
		print(player:get_player_name())
		local formspec = "background[0,4.5;8,4;ui_main_inventory.png]" ..
			"label[1,0;Missions]" ..
			"button[1,1;4,1;abort_mission;Abort mission]";


		return {formspec=formspec}
	end
})



unified_inventory.register_button("missions", {
        type = "image",
        image = "mission_block_preview.png",
        tooltip = "Missions"
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then return end
	if not player then return end

	if fields.abort_mission then
		local player_name = player:get_player_name()
		missions.abort(player_name)
	end
end)