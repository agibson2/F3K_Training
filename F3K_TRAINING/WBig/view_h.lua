--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_h.lua
	Big widget view for the 1234 task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_h.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	local widget_w, widget_h = lcd.getWindowSize()
	vbase.drawCommon( widget, task )

	lcd.color(WHITE)
	lcd.drawText( 50, 133, tostring( task.target ), MIDSIZE )
	lcd.drawText( 66, 133, ' MIN: ', 0 )
	task.timer2.draw( 144, 133, MIDSIZE )

	if task.done then
		lcd.drawText( 300, 5, 'Done !', MIDSIZE )
	end

	local check = task.getDoneList()

	local text_w, text_h = lcd.getTextSize("")
	local y = 8
	local total = 0
	for i=4,1,-1 do
		lcd.drawText( 292, y, tostring( i ), check[ i ] and INVERS or 0 )
		if check[ i ] then
			lcd.drawText( 297, y, ' OK', 0 )  --was bold and inverse
		end
		local ri = 5 - i
		task.times.draw( 333, y, ri, 0 )
		total = total + math.min( i*60, task.times.getVal( ri ) )
		y = y + text_h
	end

	--lcd.drawFilledRectangle( 281, 130, widget_w - 281, widget_h - 130, 0 )  -- was inverted bgcolor
	f3kDrawTimer( 295, 133, total, 0 )  -- was bold and inverted text
	lcd.drawText( 370, 133, "Total", 0 )

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
