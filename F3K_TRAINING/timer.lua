--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	timer.lua

	Wrapper around the timer interface
	
	countdownBeep 	integer (none, beep, voice)
	minuteBeep	bool
--]]

function f3kCreateTimer( timerId, startValue, countdownBeep, minuteBeep )
	if (DebugFunctionCalls) then print("FTRAIN: timer.f3kCreateTimer()=" .. timerId .. " startValue=" .. startValue) end
	-- Precondition: timerId is either 0 or 1
	local id = timerId
	local timer = model.getTimer(id)
	local running = false  -- Had to create something for Ethos to know if the timer is stopped or started
	
	if timer == nil then
		timer = model.createTimer(id)
		if timer == nil then
			print("FTRAIN: f3kCreateTimer() createTimer returned nil for '" .. timerId .. "'")
		else
			timer:name(timerId)
			timer:activeCondition( system.getSource(nil) ) --nil is used to stop the timer
		end
	end
	
	if countdownBeep == 1 then
		timer:audioMode(AUDIO_BEEP)
	elseif countdownBeep == 2 then
		timer:audioMode(AUDIO_VOICE)
	else
		timer:audioMode(AUDIO_MUTE)
	end
	
	if minuteBeep then
		--countdown every minute
		timer:countdownStart(540)
		timer:countdownStep(60)
	else
		-- then disable the countdown... hopefully this works
		timer:countdownStart(0)
		timer:countdownStep(60)
	end
	
	local originalStartValue = timer:start()
	local target = 0


	local function getVal()
		return timer:value()
	end

	local function getTarget()
		return target
	end

	local function start( newStartValue )
		if (DebugFunctionCalls) then print("FTRAIN: timer.start()") end

		if not newStartValue then
			newStartValue = originalStartValue
		end
		timer:start(newStartValue)
		timer:value(newStartValue)
		target = newStartValue
		--timer.mode = 1
		running = true
		if newStartValue == 0 then
			timer:direction(1)
		else
			timer:direction(-1)
		end
		
		timer:activeCondition({category=CATEGORY_ALWAYS_ON, member=1, options=0})
	end

	local function stop()
		if (DebugFunctionCalls) then print("FTRAIN: timer.stop()") end
		local wasRunning = running
		--FIXME Hack to pause timer in Ethos.. it works but unsure what it is selecting as source.
		timer:activeCondition( system.getSource({category=0, member=1, options=0}) ) 
		running = false
		return wasRunning, timer:value()
	end

	local function draw( x, y, att )
		local thetime = timer:value()
		local isnegative=false
		if thetime < 0 then
			isnegative=true
			thetime=math.abs(thetime)
		end
		
		local theseconds = thetime % 60
		local theminutes = math.floor(thetime/60)
		local texttimer
		if isnegative then
			theminutes=-theminutes
			textTimer = string.format("-%01d:%02d", theminutes, theseconds)
		else
			textTimer = string.format("%02d:%02d", theminutes, theseconds)
		end
		lcd.drawText(x, y, textTimer, LEFT)
		return val
	end

	local function drawReverse( x, y, att )
		local thetime = timer:value()
		local isnegative=false
		if thetime < 0 then
			isnegative=true
			thetime=math.abs(thetime)
		end
		
		--FIXME need to draw a box or something grey
		local theseconds = thetime % 60
		local theminutes = math.floor(thetime/60)
		local texttimer
		if isnegative then
			theminutes=-theminutes
			textTimer = string.format("-%01d:%02d", theminutes, theseconds)
		else
			textTimer = string.format("%02d:%02d", theminutes, theseconds)
		end

		lcd.drawText(x, y, textTimer, LEFT)
		return val
	end

	if startValue then
		if (DebugTimers) then print("FTRAIN: timer startValue=" .. startValue) end
		originalStartValue = startValue
		timer:start(startValue)
		timer:value(startValue)
		target = startValue
	end

	return {
		start = start,
		stop = stop,
		draw = draw,
		drawReverse = drawReverse,
		getVal = getVal,
		getTarget = getTarget
	}
end

return f3kCreateTimer
