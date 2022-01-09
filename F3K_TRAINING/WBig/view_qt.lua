--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_qt.lua
	Big widget view for the Quick Turnaround practice task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_qt.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	if (DebugFunctionCalls) then print("FTRAIN: viewQT.display()") end
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset  -- exclude right side for dashboard
	local text_w, text_h = lcd.getTextSize("0")
	vbase.drawCommon( widget, task )

	lcd.font(FONT_XL)
	local textxl_w, textxl_h = lcd.getTextSize("0")
	lcd.drawText( textxl_w * 2, 133, 'Flight ' .. math.max( 1, task.flightCount ) .. ': ', 0 )
	task.timer2.drawReverse( textxl_w * 9, 133, MIDSIZE )

	lcd.font(FONT_L)
	--lcd.drawFilledRectangle( vbase.verticaldividerx + 1, 1, widget_w - vbase.verticaldividerx - 1, 54, TEXT_INVERTED_BGCOLOR )
	lcd.drawText( vbase.verticaldividerx + 8 + text_w * 3, 8, 'Delta', INVERS )
	lcd.drawText( vbase.verticaldividerx + 8 + text_w * 1, 8 + text_h, 'min', INVERS )
	lcd.drawText( vbase.verticaldividerx + 8 + text_w * 7, 8 + text_h, 'max', INVERS )
	lcd.color(BLACK)
	lcd.drawLine( vbase.verticaldividerx, 8 + text_h * 2, widget_w, 8 + text_h * 2 ) -- line below min max
	lcd.drawLine( vbase.verticaldividerx, 8 + text_h * 3, widget_w, 8 + text_h *3 ) --separator for min max values

	local xmiddleline = vbase.verticaldividerx + 8 + 70
	lcd.drawLine( xmiddleline, 8 + text_h * 2, xmiddleline, 8 + text_h * 3, SOLID, 2 ) -- line below min max values

	lcd.color(WHITE)
	lcd.drawNumber( vbase.verticaldividerx + 8 + text_w * 5, 8 + text_h * 2, task.deltas.min, UNIT_SECOND, 0, RIGHT )
	--lcd.drawText( 321, 59, 's', 0 )
	lcd.drawNumber( vbase.verticaldividerx + 8 + text_w * 11, 8 + text_h * 2, task.deltas.max, UNIT_SECOND, 0, RIGHT )
	--lcd.drawText( 374, 59, 's', 0 )

	--lcd.drawFilledRectangle( vbase.verticaldividerx + 1, 86, widget_w - vbase.verticaldividerx - 1, 34, TEXT_INVERTED_BGCOLOR )
	lcd.drawText( vbase.verticaldividerx + 8, 8 + text_h * 3, 'average', INVERS )
	lcd.drawNumber( vbase.verticaldividerx + 8 + text_w * 11, 8 + text_h * 3, task.deltas.avg, UNIT_SECOND, 0, RIGHT )
	--lcd.drawText( 346, 124, 's', 0 )

	--lcd.color(BLACK)
	--lcd.drawLine( vbase.verticaldividerx, 133 - 8, widget_w - 1, 133 - 8, SOLID, 2 )
	lcd.color(WHITE)
	--f3kDrawTimer( 295, 133, total, 0 )  -- was bold and inverted text
	--lcd.drawText( 370, 133, "Total", 0 )

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
