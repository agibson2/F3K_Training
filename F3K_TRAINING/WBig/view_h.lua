--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_h.lua
	Big widget view for the 1234 task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_h.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( context )
	widget.drawCommon( context, task )

	OpenTX.lcd.drawText( 70, 129, tostring( task.target ), MIDSIZE )
	OpenTX.lcd.drawText( 86, 133, ' MIN: ', 0 )
	task.timer2.draw( 140, 129, MIDSIZE )

	if task.done then
		OpenTX.lcd.drawText( 300, 5, 'Done !', MIDSIZE )
	end

	local check = task.getDoneList()

	local y = 20
	local total = 0
	for i=4,1,-1 do
		y = y + 21
		OpenTX.lcd.drawText( 287, y, tostring( i ), check[ i ] and INVERS or 0 )
		if check[ i ] then
			OpenTX.lcd.drawText( 297, y, ' OK', BOLD+INVERS )
		end
		local ri = 5 - i
		task.times.draw( 333, y, ri, 0 )
		total = total + math.min( i*60, task.times.getVal( ri ) )
	end

	OpenTX.lcd.drawFilledRectangle( 281, 130, context.zone.w - 281, context.zone.h - 130, TEXT_INVERTED_BGCOLOR )  -- 52w and 11h
	f3kDrawTimer( 311, 140, total, INVERS )

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
