--[[
	F3K Training - 	Mike, ON4MJ

	task_d.lua
	Task D : Ladder (10 min window)
--]]


local taskD2 = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )


taskD2.MAX_FLIGHT_TIME = 30 	-- This won't be a constant here, but for consistency (and memory !), we'll keep it uppercase'd

taskD2.flights = {}
taskD2.current = 1
taskD2.done = false


function taskD2.earlyReset()
	if taskD2.earlyResetBase() then
		taskD2.MAX_FLIGHT_TIME = 30

		taskD2.flights = {}
		taskD2.current = 1
		taskD2.done = false

		taskD2.initFlightTimer()

		return true
	end
	return false
end


function taskD2.endOfWindow()
	if taskD2.timer1.getVal() <= 0 then
		local timeRunning, val = taskD2.timer2.stop()
		taskD2.timer1.stop()

		taskD2.playSound( 'taskend' )

		if timeRunning and not taskD2.done then
			val = taskD2.MAX_FLIGHT_TIME - val
			taskD2.flights[ taskD2.current ] = val
			if val >= taskD2. MAX_FLIGHT_TIME then
				taskD2.times.pushTime( taskD2.MAX_FLIGHT_TIME )
				taskD2.current = taskD2.current + 1
				if taskD2.MAX_FLIGHT_TIME == 120 then
					taskD2.playSound( 'welldone' )
				end
			end
		end

		taskD2.done = true
		taskD2.state = 5
		return true
	end
	return false
end

-- state functions
function taskD2.flyingState()
	if not taskD2.endOfWindow() and not taskD2.earlyReset() then
		-- Wait for the pilot to catch/land (he/she's supposed to pull the temp switch at that moment)
		if f3klanded() then
			taskD2.timer2.stop()

			local val = taskD2.timer2.getVal()
			taskD2.flights[ taskD2.current ] = taskD2.MAX_FLIGHT_TIME - val
			if val <= 0 then
				-- we did it !
				taskD2.times.pushTime( taskD2.MAX_FLIGHT_TIME ) -- store it to get the total score later

				taskD2.MAX_FLIGHT_TIME = taskD2.MAX_FLIGHT_TIME + 15
				taskD2.current = taskD2.current + 1

				if taskD2.MAX_FLIGHT_TIME > 120 then
					-- we're done, congrats !
					taskD2.timer1.stop()
					taskD2.playSound( 'welldone' )
					taskD2.done = true
					taskD2.state = 5
				else
					if taskD2.MAX_FLIGHT_TIME > taskD2.timer1.getVal() then
						-- not enough time remaining to complete the next step
						taskD2.playSound( 'cant' )
						taskD2.done = true
					else
						taskD2.initFlightTimer()

						taskD2.playSound( 'nxttarget' )
						taskD2.playTime( taskD2.MAX_FLIGHT_TIME )
					end
				end
			end
			taskD2.state = 4
		end
	end
end


-- public interface
function taskD2.init()
	taskD2.name = 'Ladder'
	taskD2.wav = 'taskD2'

	taskD2.times = createTimeKeeper( 7, 120 )	-- We'll handle the max flight time ourselves here
	taskD2.state = 1

	taskD2.initPrepTimer()
	taskD2.initFlightTimer()
end


return taskD2
