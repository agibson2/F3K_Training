--[[
	F3K Training - Mike, ON4MJ

	task_qt.lua
	Task QT : 15x40s (10 min window)
--]]


local taskQT = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )


taskQT.MAX_FLIGHT_TIME = 40
taskQT.FLIGHT_COUNT = 15

taskQT.deltas = {min = 0, max = 0, avg = 0}

taskQT.previousTime = 0


function taskQT.computeDeltas()
	local max = 0
	local min = 600
	local avg = 0

	if taskQT.flightCount > 0 then
		local tot = 0
		for i=1,taskQT.flightCount do
			local val = math.abs( taskQT.times.getVal( i ) - taskQT.MAX_FLIGHT_TIME )
			tot = tot + val
			max = math.max( max, val )
			min = math.min( min, val )
		end
		avg = tot / taskQT.flightCount
	else
		min = 0
	end

	return {
		min = min,
		max = max,
		avg = avg
	}
end



-- public interface
function taskQT.initFlightTimer()
	-- createTimer parameters : timerId, startValue, countdownBeep, minuteBeep
	taskQT.timer2 = createTimer( 1, taskQT.MAX_FLIGHT_TIME, AUDIO_MUTE, false )
end


function taskQT.init()
	taskQT.commonInit( 'QT practice', taskQT.FLIGHT_COUNT, 'taskQT' )
	taskQT.flightCount = 0
	taskQT.deltas = {min = 0, max = 0, avg = 0}
end


function taskQT.earlyReset()
	if taskQT.earlyResetBase() then
		taskQT.flightCount = 0
		taskQT.deltas = {min = 0, max = 0, avg = 0}
		taskQT.previousTime = 0
		return true
	end
	return false
end



function taskQT.flyingState()
	if not taskQT.endOfWindow() and not taskQT.earlyReset() then
		-- Wait for the pilot to catch/land/crash (he/she's supposed to pull the temp switch at that moment)
		if f3klanded() then
			taskQT.timer2.stop()
			taskQT.times.addTime( taskQT.timer2.getTarget() - taskQT.timer2.getVal() )
			taskQT.deltas = taskQT.computeDeltas()
			taskQT.state = 4
		else
			-- Here we manage most of the counting ourselves
			local t = taskQT.timer2.getVal()
			if t ~= taskQT.previousTime then
				if t > 0 and t <= 30 then
					taskQT.playNumber( t, 0, 0 )
					taskQT.previousTime = t
				end
			end
		end
	end
end


function taskQT.landedState()
	if not taskQT.endOfWindow() and not taskQT.earlyReset() then
		-- Wait for the pilot to launch the plane
		if f3klaunched() then
			local remaining = taskQT.timer1.getVal()
			if remaining < taskQT.MAX_FLIGHT_TIME then
				taskQT.timer2.start( remaining )
				taskQT.playSound( 'remaining' )
				taskQT.playTime( remaining )
			else
				taskQT.timer2.start()
			end
			if taskQT.flightCount < taskQT.FLIGHT_COUNT then
				taskQT.flightCount = taskQT.flightCount + 1
			end
			taskQT.state = 3 -- flying
		end
	end
end


return taskQT
