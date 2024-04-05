--[[
	F3K Training - Mike, ON4MJ
	                Adam, StatiC

	task_qt.lua
	Task QT : 15x40s (10 min window)
--]]


local taskQT = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )


taskQT.MAX_FLIGHT_TIME = 40
taskQT.FLIGHT_COUNT = 15

taskQT.deltas = {min = 0, max = 0, avg = 0}

taskQT.previousTime = 0

taskQT.INTRO_LENGTH = 5


function taskQT.computeDeltas()
	local max = 0
	local min = 600
	local avg = 0

	if taskQT.flightCount > 0 then
		--print("QT: FlightCount=" .. taskQT.flightCount)
		local tot = 0
		for i=1,taskQT.flightCount do
			local val = math.abs( taskQT.times.getVal( i ) - taskQT.MAX_FLIGHT_TIME )
			tot = tot + val
			max = math.max( max, val )
			min = math.min( min, val )
			--print("QT: i=" .. i .. " tot=" .. tot .. " max=" .. max .. " min=" .. min )
		end
		avg = tot / taskQT.flightCount
		--print("QT: avg=" .. avg )
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
	if (DebugFunctionCalls) then print("FTRAIN: taskQT.initFlightTimer()") end
	-- createTimer parameters : timerId, startValue, countdownBeep, minuteBeep
	taskQT.timer2 = createTimer( "f3kOne", taskQT.MAX_FLIGHT_TIME, 0, false )
end


function taskQT.init()
	if (DebugFunctionCalls) then print("FTRAIN: viewQT.init()") end
	taskQT.commonInit( 'QT practice', taskQT.FLIGHT_COUNT, 'taskQT' )
	taskQT.flightCount = 0
	taskQT.deltas = {min = 0, max = 0, avg = 0}
end


function taskQT.earlyReset(widget)
if (DebugFunctionCalls) then print("FTRAIN: viewQT.earlyReset()") end
	if taskQT.earlyResetBase(widget) then
		taskQT.flightCount = 0
		taskQT.deltas = {min = 0, max = 0, avg = 0}
		taskQT.previousTime = 0
		return true
	end
	return false
end



function taskQT.flyingState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskQT.flyingState() getval=" .. taskQT.timer2.getVal()) end
	if not taskQT.endOfWindow() and not taskQT.earlyReset(widget) then
		-- Wait for the pilot to catch/land/crash (he/she's supposed to pull the temp switch at that moment)
		if f3klanded(widget) then
			taskQT.timer2.stop()
			taskQT.times.addTime( taskQT.timer2.getTarget() - taskQT.timer2.getVal() )
			taskQT.deltas = taskQT.computeDeltas()
			taskQT.state = 4
		else
			-- Here we manage most of the counting ourselves
			local t = taskQT.timer2.getVal()
			if t ~= taskQT.previousTime then
				if t > 0 and ((t > 10 and (t % 2) == 0) or t <= 10) then  -- only announce every 2 seconds or voice gets behind timer until it gets down to 10
					system.playNumber( t, (t == 40) and UNIT_SECOND or 0, 0 )
					taskQT.previousTime = t
				end
			end
		end
	end
end


function taskQT.landedState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskQT.landedState()") end
	if not taskQT.endOfWindow() and not taskQT.earlyReset(widget) then
		-- Wait for the pilot to launch the plane
		if f3klaunched(widget) or ( widget.start_worktime_on_launch and taskQT.flightCount == 0 ) then
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
