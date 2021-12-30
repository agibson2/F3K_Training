--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_m.lua
	Big widget view for the Big Ladder task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_m.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( context )
	widget.drawCommon( context, task )

	if not task.done then
		OpenTX.lcd.drawText( 132, 133, task.MAX_FLIGHT_TIME .. 's: ', 0 )
		task.timer2.drawReverse( 184, 129, MIDSIZE )
	else
		OpenTX.lcd.drawText( 132, 129, 'Done !', MIDSIZE )
	end

	local total = 0
	for i=0,4 do
		local y = 10 + 21 * i
		local max = 60 + 30 * i
		OpenTX.lcd.drawNumber( 318, y, max, RIGHT )
		OpenTX.lcd.drawText( 318, y, 's', 0 )

		if i < task.current - 1 then
			local val = task.times.getVal( 7 - task.current + i )
			f3kDrawTimer( 338, y, val, 0 )
			total = total + math.min( max, val )
		end
	end

	OpenTX.lcd.drawFilledRectangle( 280 + 1, 126, context.zone.w - 281, context.zone.h - 126, TEXT_INVERTED_BGCOLOR )
	f3kDrawTimer( 312, 138, total, INVERS )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
