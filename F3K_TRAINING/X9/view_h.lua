--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_h.lua
	Taranis view for the 1234 task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_h.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X9/viewbase.lua' )


function task.display()
	display.drawCommon( task )

	lcd.drawText( 36, 50, tostring( task.target ), MIDSIZE )
	lcd.drawText( lcd.getLastPos(), 53, ' MIN: ', 0 )
	task.timer2.draw( lcd.getLastPos(), 50, MIDSIZE )

	if task.done then
		lcd.drawText( 166, 2, 'Done !', MIDSIZE )
	end

	local check = task.getDoneList()

	local y = 8
	local total = 0
	for i=4,1,-1 do
		y = y + 9
		lcd.drawText( 162, y, tostring( i ), check[ i ] and INVERS or 0 )
		if check[ i ] then
			lcd.drawText( lcd.getLastPos(), y, ' OK', BOLD+INVERS )
		end
		local ri = 5 - i
		task.times.draw( 185, y, ri, 0 )
		total = total + math.min( i*60, task.times.getVal( ri ) )
	end

	lcd.drawFilledRectangle( 160, 53, 52, 11, 0 )
	f3kDrawTimer( 185, 55, total, INVERS )

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
