--[[
	F3K Training - 	Mike, ON4MJ

	WBig/task_ff.lua
	Big widget view for the Free Flight task
--]]

-- Not working in 2.1.x
--local CLOCK = getFieldInfo( 'clock' ).id


local task = dofile( F3K_SCRIPT_PATH .. 'task_ff.lua' )


function task.display( widget )
	if (DebugFunctionCalls) then print("FTRAIN: ff_display()") end
	local horizontalDividerY = 115
	local verticalDividerX = 280
	local widget_w, widget_h = lcd.getWindowSize()
	
	lcd.color( lcd.RGB(25,25,25) ) -- Ethos green
	-- background rect right side
	lcd.drawFilledRectangle( verticalDividerX, 0, widget_w - verticalDividerX, widget_h - 1 )
	-- background rect bottom
	lcd.drawFilledRectangle( 0, horizontalDividerY, verticalDividerX, widget_h - horizontalDividerY )
	-- outline left side
	lcd.color(BLACK)
	lcd.drawLine( 0, horizontalDividerY, 0, widget_h, SOLID )
	-- outline at top of right box
	lcd.drawLine( verticalDividerX, 0, widget_h, 0, SOLID )
	-- outline at right side
	lcd.drawLine( widget_w, 0, widget_w, widget_h, SOLID )
	-- outline at bottom
	lcd.drawLine( 0, widget_h, widget_w, widget_h, SOLID )
	-- top of horizontal box
	lcd.drawLine( 0, horizontalDividerY, verticalDividerX, horizontalDividerY, SOLID )
	-- left of vertical box
	lcd.drawLine( verticalDividerX, 0, verticalDividerX, widget_h - 1, SOLID )

	lcd.color(WHITE)
	lcd.drawText( 10, 133, task.name, 0 )
	
	lcd.font(L)
	task.timer1.draw( 55, 13, 0 )
	task.timer2.draw( 120, 133, 0 )
	--f3kDrawTimer( 190, 133, getValue( 'clock' ), 0 )

	for i=0,9 do
		task.times.draw( 312, 3 + 16*i, i+1, 0 )
	end
	return task.background(widget)
end


return { init=task.init, background=task.background, display=task.display }
