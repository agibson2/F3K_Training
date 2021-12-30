local display = {}


function display.drawCommon( task )
	task.timer1.draw( 24, 4, XXLSIZE )

	lcd.drawLine( 0, 47, 159, 47, SOLID, 2 )
	lcd.drawText( 2, 53, task.name, 0 )
	lcd.drawLine( 159, 0, 159, 63, SOLID, 2 )
end


function display.drawCommonLastBest( task )
	display.drawCommon( task )

	lcd.drawText( 72, 53, 'Current: ', 0 )
	task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )

	lcd.drawFilledRectangle( 160, 53, 52, 11, 0 )
	f3kDrawTimer( 180, 55, task.times.getTotal(), INVERS )
end


return display