local display = {}


function display.drawCommon( task )
	lcd.drawText( 2, 2, task.name, 0 )
	task.timer1.draw( 24, 18, DBLSIZE )

	lcd.drawLine( 0, 47, 89, 47, SOLID, 2 )
	lcd.drawLine( 90, 0, 90, 63, SOLID, 2 )
end

function display.drawCommonLarge( task )
	lcd.drawText( 2, 2, task.name, 0 )
	task.timer1.draw( 22, 18, DBLSIZE )

	lcd.drawLine( 0, 47, 83, 47, SOLID, 2 )
	lcd.drawLine( 84, 0, 84, 63, SOLID, 2 )
end

function display.drawCommonLastBest( task )
	display.drawCommon( task )

	lcd.drawText( 2, 53, 'Current: ', 0 )
	task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )

	lcd.drawFilledRectangle( 91, 53, 37, 11, 0 )
	f3kDrawTimer( 100, 55, task.times.getTotal(), INVERS )
end


return display