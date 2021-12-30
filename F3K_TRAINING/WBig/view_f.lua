--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_f.lua
	Big widget view for the Three Out Of Six task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_f.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( context )
	widget.drawCommon( context, task )

	if task.wellDone or (task.flightCount == 6 and task.state ~= 3) then
		OpenTX.lcd.drawText( 104, 129, 'Done !', MIDSIZE )
	else
		OpenTX.lcd.drawText( 64, 133, 'Flight ', 0 )
		OpenTX.lcd.drawText( 112, 129, '#', MIDSIZE )
		OpenTX.lcd.drawText( 132, 129, tostring( math.max( 1, task.flightCount ) ), MIDSIZE )
		OpenTX.lcd.drawText( 146, 133, ': ', 0 )
		task.timer2.drawReverse( 160, 129, MIDSIZE )
	end

	for i=0,5 do
		task.times.draw( 312, 5 + 21*i, i+1, 0 )
	end
	OpenTX.lcd.drawFilledRectangle( 281, 139, context.zone.w - 281, context.zone.h - 139, TEXT_INVERTED_BGCOLOR )
	f3kDrawTimer( 312, 145, task.times.getTotal( 3 ), INVERS )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
