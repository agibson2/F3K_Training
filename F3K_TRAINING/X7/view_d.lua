--[[
	F3K Training - 	Mike, ON4MJ

	X7/view_d.lua
	Q7 view for the Ladder task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_d.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X7/viewbase.lua' )


function task.display()
	display.drawCommonLarge( task )

	lcd.drawFilledRectangle(85, 48, 43, 16, 0)
	if task.done then
		lcd.drawText( 10, 50, 'Done !', MIDSIZE )
	else
		lcd.drawText( 4, 53, task.MAX_FLIGHT_TIME .. 's: ', SMLSIZE )
		task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )
	end

	if task.current > 1 then
		lcd.drawFilledRectangle( 85, 0, 43, 1 + 9 * (task.current - 1), 0 )
	end

	for i=0,1 do
		local att = 0
		if i < task.current - 1 then
			att = INVERS
		end
		local y = 2 + 9 * i 
		--lcd.drawNumber( 100, y, 30 + 15 * i, att + RIGHT + SMLSIZE )
		--lcd.drawText( lcd.getLastPos(), y, 's', att + SMLSIZE )
		if i < task.current -1 then				
			local val = task.times.getVal( 4-task.current+i )
			--if val then
			f3kDrawTimer( 106, y, val, att + SMLSIZE )
			--end
		end
	end
	f3kDrawTimer( 106, 52, task.times.getTotal(), INVERS + SMLSIZE )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
