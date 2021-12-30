--[[
	F3K Training - 	Mike, ON4MJ

	task_h.lua
	Task H : 1234 (10 min window)
--]]


local taskH = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )


taskH.MAX_FLIGHT_TIME = 240

taskH.target = 4
taskH.done = false
taskH.previousTime = 0


function taskH.getDoneList()
	local ret = { false, false, false, false }
	local check = { 1, 2, 3, 4 }
	for i=4,1,-1 do
		for k,v in pairs( check ) do
			local t = taskH.times.getVal( v )
			if t > 0 and t > i*60-30 then
				ret[ i ] = true
				--check[ k ] = nil	crashes on the TX when the script is loaded ???
				check[ k ] = null	-- but a nil variable is ok ???
				break
			end
		end
	end
	return ret
end


function taskH.initFlightTimer()
	taskH.timer2 = createTimer( 1, 0, 0, true )	-- current flight time, going up here
end


function taskH.endOfWindow()
	if taskH.timer1.getVal() <= 0 then
		local timeRunning, val = taskH.timer2.stop()
		taskH.timer1.stop()

		if timeRunning then
			taskH.times.addTime( val )
		end
		taskH.playSound( 'taskend' )
		taskH.state = 5
		return true
	end
	return false
end


function taskH.earlyReset()
	if taskH.earlyResetBase() then
		taskH.target = 4
		taskH.done = false
		taskH.previousTime = 0
		return true
	end
	return false
end


-- state functions
function taskH.flyingState()
	if not taskH.endOfWindow() and not taskH.earlyReset() then
		-- Wait for the pilot to catch/land (he/she's supposed to pull the temp switch at that moment)
		if f3klanded() then
			taskH.timer2.stop()

			local val = taskH.timer2.getVal()
			taskH.times.addTime( val )

			if taskH.times.getVal( 4 ) > taskH.timer1.getVal() then
				-- not enough time remaining to improve
				if not taskH.done then
					taskH.playSound( 'cant' )
					taskH.done = true
				end
			end

			-- that strategy algorithm could be improved...
			if val >= taskH.MAX_FLIGHT_TIME - 30 then
				local check = taskH.getDoneList()
				while taskH.target > 1 do
					taskH.target = taskH.target - 1
					if not check[ taskH.target ] then
						taskH.MAX_FLIGHT_TIME = 60 * taskH.target
						break
					end
				end
			end

			taskH.state = 4
		else
			-- Here we manage most of the counting ourselves
			local t = taskH.timer2.getVal()
			if t ~= taskH.previousTime then
				local sec = t % 60
				if sec > 44 or sec == 30 then
					taskH.playNumber( sec, (sec == 30) and OpenTX.SECONDS or 0, 0 )
					taskH.previousTime = t
				end
			end
		end
	end
end


-- public interface
function taskH.init()
	taskH.name = '1234'
	taskH.wav = 'taskh'

	taskH.times = createTimeKeeper( 4, taskH.MAX_FLIGHT_TIME )
	taskH.state = 1

	taskH.initPrepTimer()
	taskH.initFlightTimer()
end


return taskH
