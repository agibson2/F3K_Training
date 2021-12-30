--[[
	F3K Training - 	Mike, ON4MJ

	besttaskbase.lua
	Specific state functions for "best" task serie (again, this will be overrided by specific tasks if needed)
--]]

local taskBase = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )



taskBase.BEST_COUNT = 0
taskBase.saidSorry = false


function taskBase.earlyReset()
	if taskBase.earlyResetBase() then
		taskBase.saidSorry = false
		return true
	end
	return false
end

function taskBase.landedState()
	if not taskBase.endOfWindow() and not taskBase.earlyReset() then
		local remaining = taskBase.timer1.getVal()
		if remaining < taskBase.times.getVal( taskBase.BEST_COUNT ) then
			if not taskBase.saidSorry then		
				taskBase.playSound( 'cant' )
				taskBase.saidSorry = true
			end
		end

		-- Wait for the pilot to launch the plane
		if f3klaunched() then
			if remaining < taskBase.MAX_FLIGHT_TIME then
				taskBase.timer2.start( remaining )
				taskBase.playSound( 'remaining' )
				taskBase.playTime( remaining )
			else
				taskBase.timer2.start()
			end
			taskBase.state = 3 -- flying
		end
	end
end


return taskBase
