--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	task_l.lua
	Task L : One Flight only (10 min window)
	During the working time, the competitor may launch his model glider one single time. The maximum flight time is limited to 599 seconds (9 minutes 59 seconds).  Working time: 10 minutes.
--]]


local taskL = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )

taskL.MAX_FLIGHT_TIME = 599 	-- This won't be a constant here, but for consistency (and memory !), we'll keep it uppercase'd
taskL.TIMES_SORTED = false

taskL.current = 1
taskL.done = false
taskL.COUNT = 1

function taskL.earlyReset(widget) 
	if taskL.earlyResetBase(widget) then
		taskL.MAX_FLIGHT_TIME = 599

		taskL.current = 1
		taskL.done = false

		taskL.initFlightTimer()

		return true
	end
	return false
end


function taskL.endOfWindow()
	if taskL.timer1.getVal() <= 0 then
		local timeRunning, val = taskL.timer2.stop()
		taskL.timer1.stop()

		taskL.playSound( 'taskend' )

		if timeRunning and not taskL.done then
			val = taskL.MAX_FLIGHT_TIME - val
			taskL.times.pushTime( val )
			taskL.current = taskL.current + 1
		end

		taskL.done = true
		taskL.state = 5
		return true
	end
	return false
end


-- state functions
function taskL.flyingState(widget)
	if not taskL.endOfWindow() and not taskL.earlyReset(widget) then
		-- Wait for the pilot to catch/land (he/she's supposed to pull the temp switch at that moment)
		if f3klanded(widget) then
			taskL.timer2.stop()
			taskL.times.pushTime( taskL.MAX_FLIGHT_TIME - taskL.timer2.getVal() )
			taskL.current = taskL.current + 1
			
			if taskL.current > taskL.COUNT then
				taskL.timer1.stop()
				taskL.done = true
				taskL.playSound( 'taskend' )
				taskL.state = 5
			else
				taskL.initFlightTimer()
				taskL.playSound( 'nxttarget' )
				taskL.playTime( taskL.MAX_FLIGHT_TIME )
				taskL.state = 4
			end
		end
	end
end



-- public interface
function taskL.init()
	taskL.name = 'One flight'
	taskL.wav = 'taskL'

	taskL.times = createTimeKeeper( taskL.COUNT, 600 )	-- We'll handle the max flight time ourselves here
	taskL.state = 1

	taskL.initPrepTimer()
	taskL.initFlightTimer()
	taskL.timer1.stop()
	taskL.timer2.stop()
end


return taskL

