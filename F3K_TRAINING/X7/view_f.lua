--[[
	F3K Training - 	Mike, ON4MJ

	X7/view_f.lua
	Q7 view for the Three Out Of Six task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_f.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X7/viewbase.lua' )


function task.display()
	display.drawCommon( task )

	if task.wellDone or (task.flightCount == 6 and task.state ~= 3) then
		lcd.drawText( 25, 50, 'Done !', MIDSIZE )
	else
		lcd.drawText( 12, 50, '#', MIDSIZE )
		lcd.drawText( lcd.getLastPos(), 50, tostring( math.max( 1, task.flightCount ) ), MIDSIZE )
		lcd.drawText( lcd.getLastPos(), 53, ': ', 0 )
		task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )
	end

	for i=0,5 do
		task.times.draw( 100, 1 + 9*i, i+1, 0 )
	end
	lcd.drawFilledRectangle( 91, 55, 37, 9, 0 )
	f3kDrawTimer( 100, 56, task.times.getTotal( 3 ), INVERS )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
