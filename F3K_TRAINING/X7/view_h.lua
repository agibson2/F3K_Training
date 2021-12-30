--[[
	F3K Training - 	Mike, ON4MJ

	X7/view_h.lua
	Q7 view for the 1234 task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_h.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X7/viewbase.lua' )


function task.display()
	lcd.drawText( 2, 2, task.name, 0 )
	task.timer1.draw( 22, 18, DBLSIZE )

	lcd.drawLine( 0, 47, 79, 47, SOLID, 2 )
	lcd.drawLine( 80, 0, 80, 63, SOLID, 2 )

	lcd.drawText( 8, 50, tostring( task.target ), MIDSIZE )
	lcd.drawText( lcd.getLastPos(), 53, ' MIN: ', 0 )
	task.timer2.draw( lcd.getLastPos(), 50, MIDSIZE )

	if task.done then
		lcd.drawText( 84, 1, 'Done !', MIDSIZE )
	end

	local check = task.getDoneList()

	local y = 8
	local total = 0
	for i=4,1,-1 do
		y = y + 9
		lcd.drawText( 83, y, tostring( i ), check[ i ] and INVERS or 0 )
		if check[ i ] then
			lcd.drawText( 90, y, 'OK', BOLD + INVERS )
		end
		local ri = 5 - i
		task.times.draw( 104, y, ri, 0 )
		total = total + math.min( i*60, task.times.getVal( ri ) )
	end

	lcd.drawFilledRectangle( 81, 53, 47, 11, 0 )
	f3kDrawTimer( 104, 55, total, INVERS )

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
