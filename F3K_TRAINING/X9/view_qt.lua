--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_qt.lua
	Taranis view for the Quick Turnaround practice task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_qt.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X9/viewbase.lua' )


function task.display()
	display.drawCommon( task )

	lcd.drawText( 72, 53, 'Flight ' .. math.max( 1, task.flightCount ) .. ': ', 0 )
	task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )

	lcd.drawFilledRectangle( 160, 0, 52, 20, 0 )
	lcd.drawText( 174, 2, 'Delta', INVERS )
	lcd.drawText( 168, 11, 'min', INVERS )
	lcd.drawText( 191, 11, 'max', INVERS )

	lcd.drawLine( 186, 20, 186, 31, SOLID, 2 )

	lcd.drawNumber( 178, 22, task.deltas.min, RIGHT )
	lcd.drawText( lcd.getLastPos(), 22, 's', 0 )
	lcd.drawNumber( 204, 22, task.deltas.max, RIGHT )
	lcd.drawText( lcd.getLastPos(), 22, 's', 0 )

	lcd.drawFilledRectangle( 160, 32, 52, 10, 0 )
	lcd.drawText( 165, 33, 'average', INVERS )
	lcd.drawNumber( 190, 44, task.deltas.avg, RIGHT )
	lcd.drawText( lcd.getLastPos(), 44, 's', 0 )

	lcd.drawLine( 160, 55, 211, 55, SOLID, 2 )
	lcd.drawText( 161, 57, 'Total', INVERS + SMLSIZE )
	f3kDrawTimer( 187, 57, task.times.getTotal(), SMLSIZE )

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
