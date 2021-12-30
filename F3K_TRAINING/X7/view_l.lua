--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	view_l.lua
	Task L : One Flight only (10 min window)
	During the working time, the competitor may launch his model glider one single time. The maximum flight time is limited to 599 seconds (9 minutes 59 seconds).  Working time: 10 minutes.
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_l.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X7/viewbase.lua' )


function task.display()
	display.drawCommonLarge( task )

	if not task.done then
		lcd.drawText( 10, 53, '9:59: ', 0 )
		task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )
	else
		lcd.drawText( 22, 50, 'Done !', MIDSIZE )
	end

	local total = 0
	for i=0,0 do
		local y = 2
		local max = 600

		lcd.drawText( 100, y, '9:59', 0 )

		local val = task.times.getVal( 3-task.current+i )
		f3kDrawTimer( 106, y, val, 0 )
		total = total + math.min( max, val )

	end

	lcd.drawFilledRectangle( 85, 47, 52, 18, 0 )
	f3kDrawTimer( 106, 53, total, INVERS )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }