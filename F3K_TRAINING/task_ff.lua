--[[
	F3K Training - 	Mike, ON4MJ

	task_ff.lua
	Free flight : start a simple timer when the launch switch is released
	This removes the need to have a copy of the model if you're not flying tasks
--]]

-- Not working in 2.1.x
--local CLOCK = getFieldInfo( 'clock' ).id


local taskFF = {
	running = true,

	times,	-- best times (time keeper object)

	timer1,	-- work time

	state,	-- 1=reset; 2=start; 3=flying; 4=landed, 5=end

	name,
	wav
}



function taskFF.playSound( sound )
	system.playFile( SOUND_PATH .. sound .. '.wav' )
end


function taskFF.initTimers()
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.initTimers()") end
	-- createTimer parameters : timerId, startValue, countdownBeep, minuteBeep
	taskFF.timer1 = f3kCreateTimer( "f3kZero", 0, 0, true )	-- current flight time
	taskFF.timer2 = f3kCreateTimer( "f3kOne", 0, 0, false )
end


function taskFF.init()
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.init()") end
	taskFF.name = 'Free Flight'
	taskFF.wav = 'taskff'

	taskFF.times = createTimeKeeper( 10, 0 )
	taskFF.state = 1 	-- 1=reset
	taskFF.initTimers()
end


-- Recurring tests of the end of task conditions (user reset or work time ellapsed)
function taskFF.earlyReset(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.earlyReset()") end
	if not widget.startswitch:state() then
		-- Stop the timers and reset the internal state
		taskFF.timer1.stop()
		taskFF.timer2.stop()
		taskFF.state = 1
		return true
	end
	return false
end


-- State functions
function taskFF.resetState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.resetState()") end
	-- Wait for the start of the task
	if widget.startswitch:state() then
		taskFF.playSound( taskFF.wav )

		-- reset the scores
		taskFF.times.reset()

		taskFF.initTimers()
		taskFF.timer2.start()

		taskFF.state = 2
	elseif not widget.menuswitch:state() then
		taskFF.running = false
	end
end



function taskFF.startedState()
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.startedState()") end
	taskFF.state = 4
end


function taskFF.flyingState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.flyingState()") end
	if not taskFF.earlyReset(widget) then
		-- Wait for the pilot to catch/land/crash (he/she's supposed to pull the temp switch at that moment)
		if f3klanded(widget) then  --FIXME not sure if this is supposed to be F3KConfig.landed()
			taskFF.timer1.stop()
			local val = taskFF.timer1.getVal()
			if val > 0 then
				taskFF.times.pushTime( val )
			end
			taskFF.state = 4
		end
	end
end


function taskFF.landedState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.landedState()") end
	if not taskFF.earlyReset(widget) then
		-- Wait for the pilot to launch the plane
		if f3klaunched(widget) then
			taskFF.timer1.start()
			taskFF.state = 3
		end
	end
end


function taskFF.endState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.endState()") end
	-- Wait for reset
	if taskFF.earlyReset(widget) then
		resetLaunchDetection()
	end
end


function taskFF.backgroundState()
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.backgroundState()") end
	return taskFF.running
end	


local lasttimestamp = 0
-- Run the correct function based on the current state
function taskFF.background(widget)
	local newtimestamp = os.clock()
	if (newtimestamp - lasttimestamp > 1) then
		lcd.invalidate()
		lastrefreshtime = newtimestamp
	end
	({ taskFF.resetState, taskFF.startedState, taskFF.flyingState, taskFF.landedState, taskFF.endState })[ taskFF.state ](widget)
	return taskFF.running
end


return taskFF
