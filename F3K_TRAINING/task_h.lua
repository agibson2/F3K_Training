--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	task_h.lua
	Task H : 1234 (10 min window)
--]]


local taskH = dofile( F3K_SCRIPT_PATH .. 'taskbase.lua' )


taskH.MAX_FLIGHT_TIME = 240

taskH.target = 4
taskH.done = false
taskH.previousTime = 0
taskH.COUNT = 4


function taskH.getDoneList()
	local ret = { false, false, false, false }
	local check = { 1, 2, 3, 4 }
	for i=taskH.COUNT,1,-1 do
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
	taskH.timer2 = createTimer( "f3kOne", 0, AUDIO_MUTE, true )	-- current flight time, going up here
	
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


function taskH.earlyReset(widget)
	if taskH.earlyResetBase(widget) then
		taskH.target = 4
		taskH.done = false
		taskH.previousTime = 0
		return true
	end
	return false
end


-- state functions
function taskH.flyingState(widget)
	if not taskH.endOfWindow() and not taskH.earlyReset(widget) then
		-- Wait for the pilot to catch/land (he/she's supposed to pull the temp switch at that moment)
		if f3klanded(widget) then
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
				local minfract = t / 60
				local min = math.floor( minfract )
				if sec == 30 or sec == 45 then
					if min > 0 then
						system.playNumber( min, UNIT_MINUTE, 0 )
					end
					system.playNumber( sec, UNIT_SECOND, 0 )  -- play full number plus seconds at 30 and 45
				elseif (sec > 49) then
					last10 = 60 - sec
					system.playNumber( last10, 0, 0 )  -- play the last 10 seconds up to next minute
				elseif min > 0 and sec == 0 then
					system.playNumber( min, UNIT_MINUTE, 0 )  -- also announce top of the minute
					
					if taskH.target == min then
						taskH.playSound("targach")
						local check = taskH.getDoneList()
						local nexttarg = nil
						for i=4,1,-1 do
							if not check[i] and i ~= taskH.target then
								nexttarg = i
								break
							end
						end
						if nexttarg ~= nil then
							taskH.playSound("nxttarget")
							system.playNumber(nexttarg, UNIT_MINUTE, 0) -- anounce next target if we meet the time
						end
					end
				elseif min + 1 == taskH.target and sec == 15 then
					taskH.playSound("target45")
				end
				
				taskH.previousTime = t
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
	taskH.timer1.stop()
	taskH.timer2.stop()
end


return taskH
