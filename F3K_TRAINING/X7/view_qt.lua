--[[
	F3K Training - 	Mike, ON4MJ

	X7/view_qt.lua
	Q7 view for the Quick Turnaround practice task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_qt.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X7/viewbase.lua' )


function task.display()
	display.drawCommonLarge( task )

	lcd.drawText( 2, 53, 'Flight ' .. math.max( 1, task.flightCount ) .. ': ', 0 )
	task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )

	lcd.drawFilledRectangle( 85, 0, 43, 20, 0 )
	lcd.drawText( 92, 2, 'Delta', INVERS )
	lcd.drawText( 87, 11, 'min', INVERS )
	lcd.drawText( 109, 11, 'max', INVERS )

	lcd.drawLine( 106, 20, 106, 31, SOLID, 2 )

	lcd.drawNumber( 100, 22, task.deltas.min, RIGHT )
	lcd.drawText( lcd.getLastPos(), 22, 's', 0 )
	lcd.drawNumber( 122, 22, task.deltas.max, RIGHT )
	lcd.drawText( lcd.getLastPos(), 22, 's', 0 )

	lcd.drawFilledRectangle( 85, 32, 43, 10, 0 )
	lcd.drawText( 86, 33, 'average', INVERS )
	lcd.drawNumber( 110, 45, task.deltas.avg, RIGHT )
	lcd.drawText( lcd.getLastPos(), 45, 's', 0 )

	lcd.drawLine( 85, 55, 127, 55, SOLID, 2 )
	lcd.drawText( 86, 57, 'Tot.', INVERS + SMLSIZE )
	f3kDrawTimer( 105, 57, task.times.getTotal(), SMLSIZE )

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
