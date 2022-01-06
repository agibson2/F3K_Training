--[[
	F3K Training - 	Mike, ON4MJ

	timer.lua

	Wrapper around the timer interface
	
	countdownBeep 	integer (none, beep, voice)
	minuteBeep	bool
--]]

function f3kCreateTimer( timerId, startValue, countdownBeep, minuteBeep )
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
			
	-- if timerId == 'f3kOne' then
		-- print("FTRAIN: timer: f3kCreateTimer() Setting audiomode to voice and setting countdown start and step")
		-- timer:countdownStart(60)
		-- timer:countdownStep(30)
	-- end
	
	local originalStartValue = timer:start()
	local target = 0


	local function getVal()
		return timer:value()
	end

	local function getTarget()
		return target
	end

	local function start( newStartValue )
		--model.resetTimer( id )

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

		--model.setTimer( id, timer )  --OpenTx way to set timer parameters
	end

	local function stop()
		local wasRunning = running
		--FIXME Hack to pause timer in Ethos.. it works but unsure what it is selecting as source.
		timer:activeCondition( system.getSource({category=0, member=1, options=0}) ) 

		return wasRunning, timer:value()
	end

	local function draw( x, y, att )
		local thetime = timer:value()
		local theseconds = thetime % 60
		local theminutes = math.floor(thetime/60)
		local textTimer = string.format("%02d:%02d", theminutes, theseconds)
		lcd.drawText(x, y, textTimer, LEFT)
		return val
	end

	local function drawReverse( x, y, att )
		local thetime = timer:value()
		local theseconds = thetime % 60
		local theminutes = math.floor(thetime/60)
		--FIXME need to draw a box or something grey
		local textTimer = string.format("%02d:%02d", theminutes, theseconds)
		lcd.drawText(x, y, textTimer, LEFT)
		return val
	end


	-- "constructor"
	--timer.countdownBeep = countdownBeep
	--timer.minuteBeep = minuteBeep
	--timer.persistent = 0

	if startValue then
		originalStartValue = startValue
		timer:start(startValue)
		timer:value(startValue)
		target = startValue
	end

	--FIXME need to pause/disable timer when Ethos supports it
	--timer.mode = 0
	--model.setTimer( id, timer )


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
