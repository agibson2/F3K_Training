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
	local stoppedTime = 0  -- if timer is stopped, the stopped time is stored here because I can't find a way to pause the timer in Ethos
	
	if timer == nil then
		timer = model.createTimer(id)
		if timer == nil then
			print("FTRAIN: f3kCreateTimer() createTimer returned nil for '" .. timerId .. "'")
		else
			timer:name(timerId)
		end
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
		
		timer:activeCondition({category=CATEGORY_ALWAYS_ON})

		--model.setTimer( id, timer )  --OpenTx way to set timer parameters
	end

	local function stop()
		local wasRunning = running --FIXME no pause/disable timer yet (timer.mode > 0)
		timer:activeCondition(nil)
		running = false
		stoppedTime = timer:value()
		--model.setTimer( id, timer )
		--FIXME need to pause/disable timer when Ethos supports it
		return wasRunning, stoppedTime
	end

	local function draw( x, y, att )
		local thetime
		if (running) then
			thetime = timer:value()
		else
			thetime = stoppedTime
		end
		local theseconds = thetime % 60
		local theminutes = math.floor(thetime/60)
		local textTimer = string.format("%02d:%02d", theminutes, theseconds)
		lcd.drawText(x, y, textTimer, LEFT)
		return val
	end

	local function drawReverse( x, y, att )
		if (running) then
			thetime = timer:value()
		else
			thetime = stoppedTime
		end
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
