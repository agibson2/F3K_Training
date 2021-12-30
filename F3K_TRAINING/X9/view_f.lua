--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_f.lua
	Taranis view for the Three Out Of Six task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_f.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X9/viewbase.lua' )


function task.display()
	display.drawCommon( task )

	if task.wellDone or (task.flightCount == 6 and task.state ~= 3) then
		lcd.drawText( 56, 50, 'Done !', MIDSIZE )
	else
		lcd.drawText( 42, 53, 'Flight ', 0 )
		lcd.drawText( lcd.getLastPos(), 50, '#', MIDSIZE )
		lcd.drawText( lcd.getLastPos(), 50, tostring( math.max( 1, task.flightCount ) ), MIDSIZE )
		lcd.drawText( lcd.getLastPos(), 53, ': ', 0 )
		task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )
	end

	for i=0,5 do
		task.times.draw( 180, 1 + 9*i, i+1, 0 )
	end
	lcd.drawFilledRectangle( 160, 55, 52, 9, 0 )
	f3kDrawTimer( 180, 56, task.times.getTotal( 3 ), INVERS )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
