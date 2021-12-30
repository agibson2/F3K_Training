--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_d.lua
	Taranis view for the Ladder task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_d2.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X9/viewbase.lua' )


function task.display()
	display.drawCommon( task )

	lcd.drawFilledRectangle( 121, 48, 38, 16, 0 )
	if not task.done then
		lcd.drawText( 48, 53, task.MAX_FLIGHT_TIME .. 's: ', 0 )
		task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )
	else
		lcd.drawText( 56, 50, 'Done !', MIDSIZE )
	end

	if task.current > 1 then
		lcd.drawFilledRectangle( 160, 0, 52, 1 + 9 * (task.current - 1), 0 )
	end

	for i=0,6 do
		local att = 0
		if i < task.current - 1 then
			att = INVERS
		end

		local y = 2 + 9 * i
		lcd.drawNumber( 176, y, 30 + 15 * i, att + RIGHT )
		lcd.drawText( lcd.getLastPos(), y, 's', att )

		if i < task.current then
			local val = task.flights[ i+1 ]
			if val then
				f3kDrawTimer( 187, y, val, att )
			end
		end
	end

	f3kDrawTimer( 129, 53, task.times.getTotal(), INVERS )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
