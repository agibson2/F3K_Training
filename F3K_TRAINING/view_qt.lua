--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_qt.lua
	Big widget view for the Quick Turnaround practice task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_qt.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	if (DebugFunctionCalls) then print("FTRAIN: viewQT.display()") end
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset  -- exclude right side for dashboard
	lcd.font(FONT_L)
	local text_w, text_h = lcd.getTextSize("0")
	vbase.drawCommon( widget, task )

	lcd.font(FONT_XL)
	local textxl_w, textxl_h = lcd.getTextSize("0")
	lcd.drawText( (textxl_w * 1 / 2), textxl_h * 5, 'Flight ' .. math.max( 1, task.flightCount ) )
	task.timer2.drawReverse( textxl_w * 8, textxl_h * 5, 0 )

	lcd.font(FONT_L)
	lcd.drawText( vbase.verticaldividerx + 8 + text_w * 3, 8, 'Delta' )
	lcd.drawText( vbase.verticaldividerx + 8 + text_w * 1, 8 + text_h, 'min' )
	lcd.drawText( vbase.verticaldividerx + 8 + text_w * 7, 8 + text_h, 'max' )
	lcd.color(BLACK)
	lcd.drawLine( vbase.verticaldividerx, 8 + text_h * 2, widget_w, 8 + text_h * 2 ) -- line below min max
	lcd.drawLine( vbase.verticaldividerx, 8 + text_h * 3, widget_w, 8 + text_h *3 ) --separator for min max values

	local xmiddleline = vbase.verticaldividerx + 8 + 70
	lcd.drawLine( xmiddleline, 8 + text_h * 2, xmiddleline, 8 + text_h * 3, SOLID, 2 ) -- line below min max values

	lcd.color(WHITE)
	lcd.drawNumber( vbase.verticaldividerx + 8 + text_w * 5, 8 + text_h * 2, task.deltas.min, UNIT_SECOND, 0, RIGHT )
	lcd.drawNumber( vbase.verticaldividerx + 8 + text_w * 11, 8 + text_h * 2, task.deltas.max, UNIT_SECOND, 0, RIGHT )

	lcd.drawText( vbase.verticaldividerx + 8, 8 + text_h * 3, 'average' )
	lcd.drawNumber( vbase.verticaldividerx + 8 + text_w * 11, 8 + text_h * 3, task.deltas.avg, UNIT_SECOND, 0, RIGHT )

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
