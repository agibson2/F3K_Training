--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_c.lua
	Big widget view for the AULD task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_c.lua' )
--local widget = {}


function task.display( widget )
	local widget_w, widget_h = lcd.getWindowSize()
	lcd.font(FONT_XL)
	task.timer2.drawReverse( 115, 44, 0 )

	local horizontaldividery = 115
	local verticaldividerx = 280
	
	lcd.color( lcd.RGB(0, 35, 0) )
	-- background rect right side
	lcd.drawFilledRectangle( verticaldividerx, 0, widget_w - verticaldividerx, widget_h - 1, 0 )
	-- background rect bottom
	lcd.drawFilledRectangle( 0, horizontaldividery, verticaldividerx, widget_h - horizontaldividery, 0 )
	-- outline left side
	lcd.color(BLACK)
	lcd.drawLine( 0, horizontaldividery, 0, widget_h, SOLID, 2 )
	-- outline at top of right box
	lcd.drawLine( verticaldividerx, 0, widget_w, 0, SOLID, 2 )
	-- outline at right side
	lcd.drawLine( widget_w, 0, widget_w, widget_h, SOLID, 2 )
	-- outline at bottom
	lcd.drawLine( 0, widget_h, widget_w, widget_h, SOLID, 2 )

	lcd.drawLine( 0, horizontaldividery, verticaldividerx, horizontaldividery, SOLID, 2 )
	lcd.font(FONT_L)
	lcd.color(WHITE)
	lcd.drawText( 10, 0, task.name, 0 )
	lcd.color(BLACK)
	lcd.drawLine( verticaldividerx, 0, verticaldividerx, widget_h - 1, SOLID, 2 )

	lcd.color(WHITE)
	if task.state == 5 then
		lcd.drawText( 110, 133, 'Done !', 0 )
	end

	for i=0,4 do
		task.times.draw( 312, 10 + 22*i, i+1, 0 )
	end
	lcd.color( lcd.RGB(0, 35, 0) )
	lcd.drawFilledRectangle( 281, 130, widget_w - 281, widget_h - 130, 0 )
	lcd.color( WHITE )
	f3kDrawTimer( 312, 139, task.times.getTotal(), 0 )
	lcd.drawText( 390, 139, "Total", 0 )

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
