
missions.validate_mission = function(pos, player)
	local steps = missions.get_steps(pos)

	for i,step in ipairs(steps) do

		local spec = missions.get_step_spec_by_type(step.type)

		if spec.validate then
			local result = spec.validate(pos, step, step.data)

			if result and result.failed then
				return {
					msg="Validation failed in step " .. i ..
						" on mission: " .. pos.x .. "/" .. pos.y .. "/" .. pos.z ..
						" with message: " .. result.msg,
					success=false,
					failed=true
				}
			end
		end
	end


	return { success=true }
end