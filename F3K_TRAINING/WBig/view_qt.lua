--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_qt.lua
	Big widget view for the Quick Turnaround practice task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_qt.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( context )
	local horizontaldividery = 115
	local verticaldividerx = 280

	widget.drawCommon( context, task )

	OpenTX.lcd.drawText( 132, 133, 'Flight ' .. math.max( 1, task.flightCount ) .. ': ', 0 )
	task.timer2.drawReverse( 204, 129, MIDSIZE )

	OpenTX.lcd.drawFilledRectangle( verticaldividerx + 1, 1, context.zone.w - verticaldividerx - 1, 54, TEXT_INVERTED_BGCOLOR )
	OpenTX.lcd.drawText( 314, 5, 'Delta', INVERS )
	OpenTX.lcd.drawText( 298, 30, 'min', INVERS )
	OpenTX.lcd.drawText( 342, 30, 'max', INVERS )

	local line1X = verticaldividerx + math.floor( context.zone.w - verticaldividerx) / 2 
	OpenTX.lcd.drawLine( line1X, 54, line1X, 86, SOLID, 2 )

	OpenTX.lcd.drawNumber( 321, 59, task.deltas.min, RIGHT )
	OpenTX.lcd.drawText( 321, 59, 's', 0 )
	OpenTX.lcd.drawNumber( 374, 59, task.deltas.max, RIGHT )
	OpenTX.lcd.drawText( 374, 59, 's', 0 )

	OpenTX.lcd.drawFilledRectangle( verticaldividerx + 1, 86, context.zone.w - verticaldividerx - 1, 34, TEXT_INVERTED_BGCOLOR )
	OpenTX.lcd.drawText( 303, 90, 'average', INVERS )
	OpenTX.lcd.drawNumber( 346, 124, task.deltas.avg, RIGHT )
	OpenTX.lcd.drawText( 346, 124, 's', 0 )

	OpenTX.lcd.drawLine( verticaldividerx, 151, context.zone.w - 1, 151, SOLID, 2 )
	OpenTX.lcd.drawText( 283, 152, 'Total', INVERS )
	f3kDrawTimer( 333, 152, task.times.getTotal(), 0 )

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
