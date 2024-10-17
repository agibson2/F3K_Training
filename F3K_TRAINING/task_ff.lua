--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	task_ff.lua
	Free flight : start a simple timer when the launch switch is released
	This removes the need to have a copy of the model if you're not flying tasks
--]]

-- Not working in 2.1.x
--local CLOCK = getFieldInfo( 'clock' ).id

LAUNCHHEIGHT_INIT = 1
LAUNCHHEIGHT_WAITFORMAXSPEED = 2
LAUNCHHEIGHT_WAITFORLESSTHANMAXSPEED = 3
LAUNCHHEIGHT_END = 4

local taskFF = {
	running = true,

	times,	-- best times (time keeper object)
	heights,  -- corresponding launch heights
	timer1,	-- work time

	state,	-- 1=reset; 2=start; 3=flying; 4=landed, 5=end

	name = '',
	heightstate = LAUNCHHEIGHT_INIT,
	launchheight = 0,
	maxvspeed = 0,  --not used yet
	maxaltitude = 0, -- Maximum altitude during flight
	wav
}

taskFF.COUNT = 9
taskFF.WINDOW_TIME = 0

function taskFF.playSound( sound )
	system.playFile( SOUND_PATH .. sound .. '.wav' )
end


function taskFF.initTimers()
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.initTimers()") end
	-- createTimer parameters : timerId, startValue, countdownBeep, minuteBeep
	taskFF.timer1 = createTimer( "f3kZero", 0, 0, true )
	taskFF.timer2 = createTimer( "f3kOne", 0, 20, false )	-- current flight time
end


function taskFF.init()
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.init()") end
	taskFF.name = 'Free Flight'
	taskFF.wav = 'taskff'

	taskFF.times = createTimeKeeper( taskFF.COUNT, 0 )
	taskFF.heights = createTimeKeeper( taskFF.COUNT, 0 )
	taskFF.state = 1 	-- 1=reset
	taskFF.initTimers()
	taskFF.timer1.stop()
	taskFF.timer2.stop()
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
local timersReset = false
local announcedTaskIntro = false
function taskFF.resetState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.resetState()") end

	if timersReset == false then
		-- reset the scores
		taskFF.times.reset()
		taskFF.heights.reset()
		taskFF.initTimers()
		timersReset = true
	end

	if announcedTaskIntro == false then
		if widget.task_intro_mode == FTRAIN_INTRO_MODE_SELECT then
			taskFF.playSound( taskFF.wav )
		end
		 announcedTaskIntro = true
	end

	-- Wait for the start of the task
	if widget.startswitch:state() then
		if widget.task_intro_mode == FTRAIN_INTRO_MODE_START then
			taskFF.playSound( taskFF.wav )
		end

		taskFF.state = 2
		taskFF.timer1.start()
        timersReset = false
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
		if f3klanded(widget) then
			taskFF.timer2.stop()
			local val = taskFF.timer2.getVal()
			if val > 0 then
				taskFF.times.pushTime( val )
				taskFF.heights.pushTime( taskFF.launchheight )
			end
			taskFF.state = 4
		end
	end
	local curraltitude = widget.sensor_altitude:value()
	if curraltitude > taskFF.maxaltitude then
		taskFF.maxaltitude = curraltitude
	end
	
	-- For launch height in FF task
	if widget.sensor_altitude ~= nil and widget.sensor_vspeed ~= nil then
		--local rudderstick = system.getSource("Rudder")  -- to debug on sim since we can't modify telemetry
		if taskFF.heightstate == LAUNCHHEIGHT_INIT then
			taskFF.launchheight = 0
			taskFF.heightstate = LAUNCHHEIGHT_WAITFORMAXSPEED
			taskFF.maxvspeed = 0
			taskFF.maxaltitude = 0
		elseif taskFF.heightstate == LAUNCHHEIGHT_WAITFORMAXSPEED then
			local currvspeed = widget.sensor_vspeed:value()
			if widget.sensor_vspeed:unit() == UNIT_FOOT then
				currvspeed = currvspeed * 0.3048  -- convert to meters for calculation
			end

			if DebugLaunchHeight and currvspeed > taskFF.maxvspeed then
				taskFF.maxvspeed = currvspeed
			end
			if currvspeed >= 10 then
			--if rudderstick:value() >= 80 then   -- to debug on sim since we can't modify telemetry
				taskFF.heightstate = LAUNCHHEIGHT_WAITFORLESSTHANMAXSPEED
			end
		elseif taskFF.heightstate == LAUNCHHEIGHT_WAITFORLESSTHANMAXSPEED then
			local currvspeed = widget.sensor_vspeed:value()
			if currvspeed < 3 then
			--if rudderstick:value() < 80 then   -- to debug on sim since we can't modify telemetry
				taskFF.heightstate = LAUNCHHEIGHT_END
				taskFF.launchheight = widget.sensor_altitude:value()
				if widget.launch_height_enabled then
					system.playNumber( taskFF.launchheight, widget.sensor_altitude:unit(), 0 )
				end
			end
		end
	end
end


function taskFF.landedState(widget)
	if (DebugFunctionCalls) then print("FTRAIN: taskFF.landedState()") end
	if not taskFF.earlyReset(widget) then
		-- Wait for the pilot to launch the plane
		if f3klaunched(widget) then
			taskFF.timer2.start()
			taskFF.state = 3
			taskFF.heightstate = LAUNCHHEIGHT_INIT
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
