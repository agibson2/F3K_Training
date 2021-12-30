--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_c.lua
	Taranis view for the AULD task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_c.lua' )
local display = {}


function task.display()
	task.timer2.drawReverse( 24, 4, XXLSIZE )

	lcd.drawLine( 0, 47, 159, 47, SOLID, 2 )
	lcd.drawText( 2, 53, task.name, 0 )
	lcd.drawLine( 159, 0, 159, 63, SOLID, 2 )

	if task.state == 5 then
		lcd.drawText( 70, 50, 'Done !', MIDSIZE )
	end

	for i=0,4 do
		task.times.draw( 180, 2 + 10*i, i+1, 0 )
	end

	lcd.drawFilledRectangle( 160, 53, 52, 11, 0 )
	f3kDrawTimer( 180, 55, task.times.getTotal(), INVERS )

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
