--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	task_c.lua
	Task C : All Up Last Down
	5 flights with a maximum of 180s; no work time.
--]]

local taskC = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )

taskC.MAX_FLIGHT_TIME = 180
taskC.COUNT = 5
taskC.INTRO_LENGTH = 4


function taskC.endOfTask()
	taskC.playSound( 'taskend' )
	taskC.state = 5 -- end
end


function taskC.earlyReset(widget)
	if not widget.startswitch:state() then
		-- Stop the timers and reset the internal state
		taskC.timer2.stop()
		taskC.flightCount = 0
		taskC.state = 1
		return true
	end
	return false
end


function taskC.startedState()
	taskC.state = 4
end


function taskC.gotDown()
	if taskC.flightCount < taskC.COUNT then
		taskC.state = 4 -- landed
	else
		taskC.state = 5
		taskC.endOfTask()
	end
end


function taskC.flyingState(widget)
	if not taskC.earlyReset(widget) then
		-- Wait for the pilot to catch/land (he/she's supposed to pull the temp switch at that moment)
		if f3klanded(widget) then
			taskC.timer2.stop()
			taskC.times.pushTime( taskC.MAX_FLIGHT_TIME - taskC.timer2.getVal() )
			taskC.gotDown()
		else
			if taskC.timer2.getVal() <= 0 then
				taskC.timer2.stop()
				taskC.times.pushTime( taskC.MAX_FLIGHT_TIME )
				taskC.gotDown()
			end
		end
	end
end


function taskC.landedState(widget)
	if taskC.flightCount < taskC.COUNT and not taskC.earlyReset(widget) then
		-- Wait for the pilot to launch the plane
		if f3klaunched(widget) or ( widget.start_worktime_on_launch and taskC.flightCount == 0 ) then
			taskC.timer2.start()
			taskC.flightCount = taskC.flightCount + 1
			taskC.state = 3
		end
	end
end


-- public interface
function taskC.init()
	taskC.name = 'AULD'
	taskC.wav = 'taskc'

	taskC.times = createTimeKeeper( taskC.COUNT, 180 )	-- We'll handle the max flight time ourselves here
	taskC.state = 1

	taskC.initFlightTimer()
end


return taskC
