--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	task_k.lua
	Task K : Big Ladder (10 min window)
--]]


local taskK = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )


taskK.MAX_FLIGHT_TIME = 60 	-- This won't be a constant here, but for consistency (and memory !), we'll keep it uppercase'd
taskK.TIMES_SORTED = false

taskK.current = 1
taskK.done = false
taskK.COUNT = 5
taskK.TARGET_STRING_ARRAY = { "60", "90", "120","150","180" }
taskK.INTRO_LENGTH = 10

function taskK.earlyReset(widget) 
	if taskK.earlyResetBase(widget) then
		taskK.MAX_FLIGHT_TIME = 60

		taskK.current = 1
		taskK.done = false

		taskK.initFlightTimer()

		return true
	end
	return false
end


function taskK.endOfWindow()
	if taskK.timer1.getVal() <= 0 then
		local timeRunning, val = taskK.timer2.stop()
		taskK.timer1.stop()

		taskK.playSound( 'taskend' )

		if timeRunning and not taskK.done then
			val = taskK.MAX_FLIGHT_TIME - val
			taskK.times.setNextTime( val )
			taskK.current = taskK.current + 1
		end

		taskK.done = true
		taskK.state = 5
		return true
	end
	return false
end


-- state functions
function taskK.flyingState(widget)
	if not taskK.endOfWindow() and not taskK.earlyReset(widget) then
		-- Wait for the pilot to catch/land (he/she's supposed to pull the temp switch at that moment)
		if f3klanded(widget) then
			taskK.timer2.stop()

			taskK.times.setNextTime( taskK.MAX_FLIGHT_TIME - taskK.timer2.getVal() )

			taskK.MAX_FLIGHT_TIME = taskK.MAX_FLIGHT_TIME + 30
			taskK.current = taskK.current + 1

			if taskK.current > taskK.COUNT then
				taskK.timer1.stop()
				taskK.playSound( 'taskend' )
				taskK.done = true
				taskK.state = 5
			else
				taskK.initFlightTimer()
				taskK.playSound( 'nxttarget' )
				taskK.playTime( taskK.MAX_FLIGHT_TIME )
				taskK.state = 4
			end
		end
	end
end



-- public interface
function taskK.init()
	taskK.name = 'Big Ladder'
	taskK.wav = 'taskK'

	taskK.times = createTimeKeeper( taskK.COUNT, 180 )	-- We'll handle the max flight time ourselves here
	taskK.state = 1

	taskK.initPrepTimer()
	taskK.initFlightTimer()
	taskK.timer1.stop()
	taskK.timer2.stop()
end


return taskK
