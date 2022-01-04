--[[
	F3K Training - 	Mike, ON4MJ

	taskbase.lua
	Provides the core functionality which will be specialized in the tasks dedicated scripts
--]]



--[[
	The tasks
	Here's a general implementation
	and then, every task overrides part of the default behaviour to perform its own job
--]]

local taskBase = {
	PREP_TIME = 16,
	WINDOW_TIME = 600,

	MAX_FLIGHT_TIME,

	TIMES_SORTED = true, 	-- The way that times are pushed in the time keeper

	name = '',

	running = true,

	times,	-- best times (time keeper object)

	timer1,	-- prep time / work time
	timer2,	-- current flight time (descending from MAX_FLIGHT_TIME)

	state,	-- 1=reset; 2=start; 3=flying; 4=landed, 5=end
	wav,


	-- a few tasks need these, so let's put them here
	flightCount = 0,

	shoutedStop = false,
	wellDone = false
}

	-- Some common stuff

function taskBase.playTime( time )
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.playTime()") end
	local val = math.floor( time / 60 )
	if val > 0 then
	    				taskBase.playSound( 'remaining' )
		system.playNumber( val, UNIT_MINUTES, 0 )
	end
	val = time % 60
	if val > 0 then
		system.playNumber( val, UNIT_SECOND, 0 )
	end
end


function taskBase.playSound( sound )
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.playSound()") end
	system.playFile( SOUND_PATH .. sound .. '.wav' )
end


function taskBase.initFlightTimer()
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.initFlightTimer()") end
	-- createTimer parameters : timerId, startValue, countdownBeep, minuteBeep
	taskBase.timer2 = f3kCreateTimer( "f3kOne", taskBase.MAX_FLIGHT_TIME, 2, true )	-- current flight time (descending from MAX_FLIGHT_TIME)
end

function taskBase.initPrepTimer()
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.PrepTimer()") end
	taskBase.timer1 = f3kCreateTimer( "f3kZero", taskBase.PREP_TIME, 2, false )
end


function taskBase.commonInit( name, scoreCnt, wavFile )
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.commonInit()") end
	taskBase.name = name
	taskBase.wav = wavFile

	taskBase.times = createTimeKeeper( scoreCnt, taskBase.MAX_FLIGHT_TIME )
	taskBase.state = 1 	-- 1=reset
	taskBase.initPrepTimer()
	taskBase.initFlightTimer()
	taskBase.timer1.stop()
	taskBase.timer2.stop()
end


-- Recurring tests of the end of task conditions (user reset or work time ellapsed)
function taskBase.earlyResetBase(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.earlyResetBase()") end
	if not widget.startswitch:state() then
		-- Stop the timers and reset the internal state
		taskBase.timer1.stop()
		taskBase.timer2.stop()

		taskBase.flightCount = 0
		taskBase.shoutedStop = false
		taskBase.wellDone = false

		taskBase.state = 1
		return true
	end
	return false
end


function taskBase.earlyReset(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.earlyReset()") end
	return taskBase.earlyResetBase(widget)
end


function taskBase.endOfWindow()
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.endOfWindow()") end
	if taskBase.timer1.getVal() <= 0 then
		local timeRunning, val = taskBase.timer2.stop()
		taskBase.timer1.stop()

		if timeRunning then
			if taskBase.TIMES_SORTED then
				taskBase.times.addTime( taskBase.timer2.getTarget() - val )
				if(DebugTimes) then print ("FTRAIN: taskbase.endOfWindow() addTime( " .. taskBase.timer2.getTarget() .. " - " .. val " )") end
			else
				if(DebugTimes) then print ("FTRAIN: taskbase.endOfWindow() pushTime( " .. taskBase.timer2.getTarget() .. " - " .. val " )") end
				taskBase.times.pushTime( taskBase.timer2.getTarget() - val )
			end
		end
		taskBase.playSound( 'taskend' )
		taskBase.state = 5
		return true
	end
	return false
end


-- State functions (default implementation)
function taskBase.resetState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.resetState() taskBase.state=" .. taskBase.state .. " menuswitch=" .. tostring(widget.menuswitch:state()) ) end
	-- Wait for the start of the task
	if widget.startswitch:state() then
		taskBase.playSound( taskBase.wav )

		-- reset the scores
		taskBase.times.reset()

		taskBase.initPrepTimer()
		taskBase.initFlightTimer()
		taskBase.timer1.start()

		taskBase.state = 2
	elseif not widget.menuswitch:state() then
		taskBase.running = false
	end
end


function taskBase.startedState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.startedState()") end
	if not taskBase.earlyReset(widget) then
		if taskBase.timer1.getVal() <= 0 then
			taskBase.timer1 = f3kCreateTimer( "f3kZero", taskBase.WINDOW_TIME, 0, false )	-- working time
			taskBase.timer1.start()

			taskBase.state = 4
		elseif f3klaunched(widget) then		-- allow the rotation to happen during prep time
			taskBase.playSound( 'badflight' )	-- but not the launch itself
		end
	end
end


function taskBase.flyingState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.flyingState()") end
	if not taskBase.endOfWindow() and not taskBase.earlyReset(widget) then
		-- Wait for the pilot to catch/land/crash (he/she's supposed to pull the temp switch at that moment)
		if f3klanded(widget) then
			taskBase.timer2.stop()
			taskBase.times.addTime( taskBase.timer2.getTarget() - taskBase.timer2.getVal() )
			if(DebugTimes) then print ("FTRAIN: taskbase.flyingState() addTime( " .. taskBase.timer2.getTarget() .. " - " .. taskBase.timer2.getVal() " )") end
			taskBase.state = 4
		end
	end
end


function taskBase.landedState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.landedState()") end
	if not taskBase.endOfWindow() and not taskBase.earlyReset(widget) then
		-- Wait for the pilot to launch the plane
		if f3klaunched(widget) then
			taskBase.timer2.start()
			taskBase.flightCount = taskBase.flightCount + 1
			taskBase.state = 3
		end
	end
end


function taskBase.endState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.endState()") end
	-- Wait for reset
	if taskBase.earlyReset(widget) then
		resetLaunchDetection()
	end
end


function taskBase.backgroundState()
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.backgroundState()") end
	return taskBase.running
end	


local lasttimestamp = 0
-- Run the correct function based on the current state
function taskBase.background(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.background()") end
	local newtimestamp = os.clock()
	if (newtimestamp - lasttimestamp > 1) then
		lcd.invalidate()
		lastrefreshtime = newtimestamp
	end
	({ taskBase.resetState, taskBase.startedState, taskBase.flyingState, taskBase.landedState, taskBase.endState })[ taskBase.state ](widget)
	return taskBase.running
end


return taskBase
