--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_m.lua
	Fly-off Task M (Increasing time by 2 minutes “Huge Ladder”)
    Each competitor must launch his/her model glider exactly three (3) times to achieve three (3) target times as follows: 3:00 (180 seconds), 5:00 (300 seconds), 7:00 (420 seconds). The targets must be flown in the increasing order as specified. The actual times of each flight up to (not exceeding) the target time will be added up and used as the final score for the task. The competitors do not have to reach or exceed the target times to count each flight time.
    Working time: 15 minutes.
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_m.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X9/viewbase.lua' )


function task.display()
	display.drawCommon( task )

	if not task.done then
		lcd.drawText( 72, 53, task.MAX_FLIGHT_TIME .. 's: ', 0 )
		task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )
	else
		lcd.drawText( 72, 50, 'Done !', MIDSIZE )
	end

	local total = 0
	for i=0,2 do
	--print("i : " .. i)
		local y = 2 + 9 * i
		local max = 180 + 120 * i
		--lcd.drawNumber( 176, y, max, RIGHT )
		if i==0 then
		lcd.drawText( 170, y, '3', RIGHT )
		end
		if i==1 then
		lcd.drawText( 170, y, '5', RIGHT )
		end
		if i==2 then
		lcd.drawText( 170, y, '7', RIGHT )
		end
		lcd.drawText( lcd.getLastPos(), y, 'm', 0 )

		if i < task.current - 1 then
		--print (7-task.current+i)
			local val = task.times.getVal( 5-task.current+i )
			--local val = task.times.getVal( 2 + 1 * i )
			
			--print (val)
			f3kDrawTimer( 187, y, val, 0 )
			total = total + math.min( max, val )
		end
	end

	lcd.drawFilledRectangle( 160, 47, 52, 18, 0 )
	f3kDrawTimer( 176, 53, total, INVERS )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
