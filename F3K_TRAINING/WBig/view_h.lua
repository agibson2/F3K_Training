--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_h.lua
	Big widget view for the 1234 task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_h.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset  -- exclude right side for dashboard
	local text_w, text_h = lcd.getTextSize("0")
	vbase.drawCommon( widget, task )

	lcd.color(WHITE)
	lcd.font(FONT_XL)
	local textxl_w, textxl_h = lcd.getTextSize("0")
	lcd.drawText( textxl_w * 2, 133, tostring( task.target ), 0 )
	lcd.drawText( textxl_w * 4, 133, ' MIN: ', 0 )
	task.timer2.draw( textxl_w * 9, 133, 0 )

	lcd.font(FONT_L)
	if task.done then
		lcd.drawText( 300, 5, 'Done !', 0 )
	end

	local check = task.getDoneList()

	local y = 8
	local total = 0
	for i=4,1,-1 do
		lcd.drawText( 292, y, tostring( i ), check[ i ] and INVERS or 0 )  --FIXME INVERS doesn't do anything on Ethos... need to remove it
		if check[ i ] then
			lcd.drawText( 292 + text_w * 2 - 8, y, 'OK', 0 )  --was bold and inverse
		end
		local ri = 5 - i
		task.times.draw( 292 + text_w * 5, y, ri, 0 )
		total = total + math.min( i*60, task.times.getVal( ri ) )
		y = y + text_h
	end
	
	local sepx = 292 + text_w * 5 - 8

	lcd.color(BLACK)
	lcd.drawLine( sepx, 0, sepx, 133 - 8 )   -- vertical divider between task 1-4 OK and timers on the right
	lcd.drawLine( vbase.verticaldividerx, 133 - 8, widget_w, 133 - 8 )  -- horizontal separater between total on bottom and timers on top
	lcd.color(WHITE)
	f3kDrawTimer( 295, 133, total, 0 )  -- was bold and inverted text
	lcd.drawText( 370, 133, "Total", 0 )

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
