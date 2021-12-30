--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_m.lua
	Taranis view for the Big Ladder practice task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_k.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X9/viewbase.lua' )


function task.display()
	display.drawCommon( task )

	if not task.done then
		lcd.drawText( 72, 53, task.MAX_FLIGHT_TIME .. 's: ', 0 )
		task.timer2.drawReverse( lcd.getLastPos(), 50, MIDSIZE )
	else
		lcd.drawText( 72, 50, 'Done !', MIDSIZE )
	end

	local total = 0
	for i=0,4 do
	--print("i : " .. i)
		local y = 2 + 9 * i
		local max = 60 + 30 * i
		lcd.drawNumber( 176, y, max, RIGHT )
		lcd.drawText( lcd.getLastPos(), y, 's', 0 )

		if i < task.current - 1 then
		--print (7-task.current+i)
			local val = task.times.getVal( 7-task.current+i )
			--local val = task.times.getVal( 2 + 1 * i )
			
			--print (val)
			f3kDrawTimer( 187, y, val, 0 )
			total = total + math.min( max, val )
		end
	end

	lcd.drawFilledRectangle( 160, 47, 52, 18, 0 )
	f3kDrawTimer( 176, 53, total, INVERS )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
