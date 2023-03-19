--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	task_f.lua
	Task F : 3 out of 6 (10 min window ; max 180s)
--]]


local taskF = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )


taskF.MAX_FLIGHT_TIME = 180
taskF.saidSorry = false
taskF.COUNT = 6


function taskF.earlyReset(widget)
	if taskF.earlyResetBase(widget) then
		taskF.saidSorry = false
		return true
	end
	return false
end


-- State functions
function taskF.flyingState(widget)
	if not taskF.endOfWindow() and not taskF.earlyReset(widget) then
		-- Wait for the pilot to catch/land (he/she's supposed to pull the temp switch at that moment)
		if f3klanded(widget) then
			taskF.timer2.stop()
			taskF.times.addTime( taskF.MAX_FLIGHT_TIME - taskF.timer2.getVal() )
			if taskF.times.getTotal( 3 ) == 540 and not taskF.wellDone then
				taskF.playSound( 'welldone' )
				taskF.wellDone = true
			end
			if taskF.flightCount < 6 then
				taskF.state = 4 -- landed
			else
				taskF.timer1.stop()
				taskF.playSound( 'stop' )
				taskF.state = 5 -- end
			end
		else
			if taskF.timer2.getVal() <= 0 and not taskF.wellDone then
				if taskF.times.getTotal( 2 ) == 360 then
					taskF.playSound( 'welldone' )
					taskF.wellDone = true
				end
			end
		end
	end
end

function taskF.landedState(widget)
	if not taskF.endOfWindow() and not taskF.earlyReset(widget) then
		local remaining = taskF.timer1.getVal()
		if remaining <= taskF.times.getVal( 3 ) and not taskF.wellDone and not taskF.saidSorry then
			taskF.playSound( 'cant' )
			taskF.saidSorry = true
		end

		-- Wait for the pilot to launch the plane
		if f3klaunched(widget) then
			if remaining < taskF.MAX_FLIGHT_TIME then
				taskF.timer2.start( remaining )
				taskF.playSound( 'remaining' )
				taskF.playTime( remaining )
			else
				taskF.timer2.start()
			end
			taskF.flightCount = taskF.flightCount + 1
			taskF.state = 3 -- flying
		end
	end
end


-- public interface
function taskF.init()
	taskF.commonInit( '3oo6', taskF.COUNT, 'taskf' )
end


return taskF
