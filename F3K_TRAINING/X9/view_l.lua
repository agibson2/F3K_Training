--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	view_l.lua
	Task L : One Flight only (10 min window)
	During the working time, the competitor may launch his model glider one single time. The maximum flight time is limited to 599 seconds (9 minutes 59 seconds).  Working time: 10 minutes.
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_l.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X9/viewbase.lua' )


function task.display()
	display.drawCommon( task )

	if not task.done then
		lcd.drawText( 72, 53, '9:59 mins: ', 0 )
		task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )
	else
		lcd.drawText( 72, 50, 'Done !', MIDSIZE )
	end

	local total = 0
	for i=0,0 do
	--print("i : " .. i)
		local y = 2 + 9 * i
		local max = 300
		--lcd.drawNumber( 176, y, 300, RIGHT )
		--lcd.drawText( lcd.getLastPos(), y, 's', 0 )
		lcd.drawText( 161, y, '9:59', 0 )

		--if i < task.current - 1 then
		--print (4-task.current+i)
			local val = task.times.getVal( 3-task.current+i )
			--local val = task.times.getVal( 2 + 1 * i )
			
			--print (val)
			f3kDrawTimer( 187, y, val, 0 )
			total = total + math.min( max, val )
		--end
	end

	lcd.drawFilledRectangle( 160, 47, 52, 18, 0 )
	f3kDrawTimer( 176, 53, total, INVERS )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }