--[[
	F3K Training - 	Mike, ON4MJ

	WBig/task_ff.lua
	Big widget view for the Free Flight task
--]]

-- Not working in 2.1.x
--local CLOCK = getFieldInfo( 'clock' ).id


local task = dofile( F3K_SCRIPT_PATH .. 'task_ff.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )

function task.display( widget )
	if (DebugFunctionCalls) then print("FTRAIN: ff_display()") end
	local widget_w, widget_h = lcd.getWindowSize()
	 
	lcd.color( widget.backgroundcolor )
	-- background rect right side
	lcd.drawFilledRectangle( vbase.verticaldividerx, 0, widget_w - vbase.verticaldividerx, widget_h - 1 )
	-- background rect bottom
	lcd.drawFilledRectangle( 0, vbase.horizontaldividery, vbase.verticaldividerx, widget_h - vbase.horizontaldividery )
	-- outline left side
	lcd.color(BLACK)
	lcd.drawLine( 0, vbase.horizontaldividery, 0, widget_h, SOLID )
	-- outline at top of right box
	lcd.drawLine( vbase.verticaldividerx, 0, widget_w, 0, SOLID )
	-- outline at right side
	lcd.drawLine( widget_w, 0, widget_w, widget_h, SOLID )
	-- outline at bottom
	lcd.drawLine( 0, widget_h, widget_w, widget_h, SOLID )
	-- top of horizontal box
	lcd.drawLine( 0, vbase.horizontaldividery, vbase.verticaldividerx, vbase.horizontaldividery, SOLID )
	-- left of vertical box
	lcd.drawLine( vbase.verticaldividerx, 0, vbase.verticaldividerx, widget_h - 1, SOLID )

	lcd.color(WHITE)
	lcd.font(FONT_L)
	lcd.drawText( 10, 0, task.name )
	
	lcd.font(FONT_XL)

	task.timer2.draw( 90, 33, 0 )
	lcd.drawText( 20, 133, "Current:" )
	task.timer1.draw( 154, 133, 0 )
	--f3kDrawTimer( 190, 133, getValue( 'clock' ), 0 )

	lcd.font(FONT_L)
	local text_w, text_h = lcd.getTextSize("")
	for i=0,9 do
		task.times.draw( 312, 3 + text_h*i, i+1, 0 )
		task.heights.drawUnit( 422, 3 + text_h*i, i+1, widget.sensor_altitude:unit(), 0, 0 )
	end
	
	
	vbase.drawDashboard( widget, task )
	return task.background(widget)
end


return { init=task.init, background=task.background, display=task.display }
