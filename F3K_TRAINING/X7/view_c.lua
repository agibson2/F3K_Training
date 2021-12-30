--[[
	F3K Training - 	Mike, ON4MJ

	X7/view_c.lua
	Q7 view for the AULD task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_c.lua' )
local display = {}


function task.display()
	lcd.drawText( 2, 2, task.name, 0 )
	task.timer2.drawReverse( 24, 18, DBLSIZE )

	lcd.drawLine( 0, 47, 89, 47, SOLID, 2 )
	lcd.drawLine( 90, 0, 90, 63, SOLID, 2 )

	if task.state == 5 then
		lcd.drawText( 25, 50, 'Done !', MIDSIZE )
	end

	for i=0,4 do
		task.times.draw( 100, 3 + 10*i, i+1, 0 )
	end

	lcd.drawFilledRectangle( 91, 53, 37, 11, 0 )
	f3kDrawTimer( 100, 55, task.times.getTotal(), INVERS )

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
