--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_d.lua
	Big widget view for the Ladder task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_d.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( context )
	widget.drawCommon( context, task )

	if task.done then
		OpenTX.lcd.drawText( 160, 129, 'Done !', MIDSIZE )
	else
		OpenTX.lcd.drawText( 140, 133, task.MAX_FLIGHT_TIME .. 's: ', 0 )
		task.timer2.drawReverse( 192, 129, MIDSIZE )
	end

	if task.current > 1 then
		OpenTX.lcd.drawFilledRectangle( 281, 1, context.zone.w - 281, 17 * (task.current - 1) + 4, TEXT_INVERTED_BGCOLOR )
	end

	for i=0,6 do
		local att = 0
		if i < task.current - 1 then
			att = INVERS
		end

		local y = 2 + 17 * i
		OpenTX.lcd.drawNumber( 314, y, 30 + 15*i, att + RIGHT )
		OpenTX.lcd.drawText( 314, y, 's', att )

		if i < task.current then
			local val = task.flights[ i+1 ]
			if val then
				f3kDrawTimer( 334, y, val, att )
			end
		end
	end

	OpenTX.lcd.drawFilledRectangle( 281, 130, context.zone.w - 281, context.zone.h - 130, TEXT_INVERTED_BGCOLOR )
	f3kDrawTimer( 312, 139, task.times.getTotal(), INVERS )

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
