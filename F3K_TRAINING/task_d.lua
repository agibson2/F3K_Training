--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	task_d.lua
	Task D : Two Flights (10 min window)
	Each competitor has two (2) flights. These two flights will be added together. The maximum accounted single flight time is 300 seconds. Working time is 10 minutes.
--]]


local taskD = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )


taskD.MAX_FLIGHT_TIME = 300 	-- This won't be a constant here, but for consistency (and memory !), we'll keep it uppercase'd
taskD.TIMES_SORTED = false

taskD.current = 1
taskD.done = false
taskD.COUNT = 2


function taskD.earlyReset(widget) 
	if taskD.earlyResetBase(widget) then
		taskD.MAX_FLIGHT_TIME = 300

		taskD.current = 1
		taskD.done = false

		taskD.initFlightTimer()

		return true
	end
	return false
end


function taskD.endOfWindow()
	if taskD.timer1.getVal() <= 0 then
		local timeRunning, val = taskD.timer2.stop()
		taskD.timer1.stop()

		taskD.playSound( 'taskend' )

		if timeRunning and not taskD.done then
			val = taskD.MAX_FLIGHT_TIME - val
			taskD.times.pushTime( val )
			taskD.current = taskD.current + 1
		end

		taskD.done = true
		taskD.state = 5
		return true
	end
	return false
end


-- state functions
function taskD.flyingState(widget)
	if not taskD.endOfWindow() and not taskD.earlyReset(widget) then
		-- Wait for the pilot to catch/land (he/she's supposed to pull the temp switch at that moment)
		if f3klanded(widget) then
			taskD.timer2.stop()
			taskD.times.pushTime( taskD.MAX_FLIGHT_TIME - taskD.timer2.getVal() )
			taskD.current = taskD.current + 1
			
			if taskD.current > 2 then
				taskD.timer1.stop()
				taskD.done = true
				taskD.playSound( 'taskend' )
				taskD.state = 5
			else
				taskD.initFlightTimer()
				taskD.playSound( 'nxttarget' )
				taskD.playTime( taskD.MAX_FLIGHT_TIME )
				taskD.state = 4
			end
		end
	end
end



-- public interface
function taskD.init()
	taskD.name = 'Two flights'
	taskD.wav = 'taskD'

	taskD.times = createTimeKeeper( taskD.COUNT, 300 )	-- We'll handle the max flight time ourselves here
	taskD.state = 1

	taskD.initPrepTimer()
	taskD.initFlightTimer()
	taskD.timer2.stop()
	taskD.timer1.stop()
end


return taskD

