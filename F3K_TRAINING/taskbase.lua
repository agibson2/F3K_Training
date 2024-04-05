--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC
					Steven, OOSteven

	taskbase.lua
	Provides the core functionality which will be specialized in the tasks dedicated scripts
--]]



--[[
	The tasks
	Here's a general implementation
	and then, every task overrides part of the default behaviour to perform its own job
--]]

local taskBase = {
	PREP_TIME = 20,
	WINDOW_TIME = 600,
	INTRO_LENGTH = 10,  --should be overrode in each task#.lua file
	prep_count_down_start = 10,

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
		system.playNumber( val, UNIT_MINUTE, 0 )
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
	taskBase.timer2 = createTimer( "f3kOne", taskBase.MAX_FLIGHT_TIME, 20, true )	-- current flight time (descending from MAX_FLIGHT_TIME)
end

function taskBase.initPrepTimer()
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.PrepTimer()") end
	taskBase.timer1 = createTimer( "f3kZero", taskBase.PREP_TIME, taskBase.prep_count_down_start, false )
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
local timersReset = false
local announcedTaskIntro = false
local announcedWaitForLaunch = false
function taskBase.resetState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.resetState() taskBase.state=" .. taskBase.state .. " menuswitch=" .. tostring(widget.menuswitch:state()) ) end

	-- reset timers so that printing Preptime shows correct prep time after a worktime ends and you want to start the same task again
	if timersReset == false then
		taskBase.times.reset()
		-- Initialize the prep time countdown to start depending on if the intro is played at start or at task selection
		if widget.task_intro_mode == FTRAIN_INTRO_MODE_START then
			taskBase.prep_count_down_start = widget.prep_time
			taskBase.PREP_TIME = widget.prep_time + taskBase.INTRO_LENGTH
		else
			taskBase.prep_count_down_start = widget.prep_time
			taskBase.PREP_TIME = widget.prep_time
		end

		if widget.start_worktime_on_launch then
			taskBase.timer1 = createTimer( "f3kZero", taskBase.WINDOW_TIME, nil, false )	-- working time
		else
			taskBase.initPrepTimer()
		end

		taskBase.initFlightTimer()
		timersReset = true
	end

	if announcedTaskIntro == false then
		if widget.task_intro_mode == FTRAIN_INTRO_MODE_SELECT then
			taskBase.playSound( taskBase.wav )
		end
		
		announcedTaskIntro = true
	end

	-- Wait for the start of the task
	if widget.startswitch:state() then
		if announcedWaitForLaunch == false then
			if widget.start_worktime_on_launch then
				taskBase.playSound( "wt4lnch" )
			end
			announcedWaitForLaunch = true
		end
		
		if not widget.start_worktime_on_launch or f3klaunched(widget) then
			if widget.task_intro_mode == FTRAIN_INTRO_MODE_START then
				taskBase.playSound( taskBase.wav )
			end

			-- reset the scores
			--taskBase.times.reset()  -- already done above

			--taskBase.initPrepTimer()  -- already done above
			--taskBase.initFlightTimer()  -- already done above
			taskBase.timer1.start()
			announcedWaitForLaunch = true
			taskBase.state = 2
			timersReset = false

		end
	elseif not widget.menuswitch:state() then
		taskBase.running = false
	end
end


function taskBase.startedState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.startedState()") end
	if not taskBase.earlyReset(widget) then
		if widget.start_worktime_on_launch or taskBase.timer1.getVal() <= 0 then
			if not widget.start_worktime_on_launch then  -- already setup timer1 in reset state for worktime instead of doing preptime there
				taskBase.timer1 = createTimer( "f3kZero", taskBase.WINDOW_TIME, nil, false )	-- working time
			end

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
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.landedState() endofWindow=" .. taskBase.endOfWindow() .. " earlyReset=" .. taskBase.earlyReset(widget) ) end
	if not taskBase.endOfWindow() and not taskBase.earlyReset(widget) then
		-- Wait for the pilot to launch the plane
		-- Or start right away if there is no prep time set and this is the first launch
		if f3klaunched(widget) or ( widget.start_worktime_on_launch and taskBase.flightCount == 0 ) then
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
	if (DebugFunctionCalls) then print("FTRAIN: taskbase.background() state=" .. taskBase.state) end
	local newtimestamp = os.clock()
	if (newtimestamp - lasttimestamp > 1) then
		lcd.invalidate()
		lastrefreshtime = newtimestamp
	end
	({ taskBase.resetState, taskBase.startedState, taskBase.flyingState, taskBase.landedState, taskBase.endState })[ taskBase.state ](widget)
	return taskBase.running
end


return taskBase
