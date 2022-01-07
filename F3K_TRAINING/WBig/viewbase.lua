--[[
	F3K Training - 	Mike, ON4MJ

	WBig/viewbase.lua
	Big widget views common stuff
--]]

local vbase = {}

-- 
--  |-----------------------|
--  |       |           | E |
--  |   A   |____B______|---|
--  |-------|           |   |
--  |   C   |    D      | F |
--  |       |           |   |
--  |-----------------------|
--
--  General layout above
--  A is usually the session timer
--  B is usually the flight timer list
--  C is usually the current flight timer
--  D is usually the accumalated valid flight time
--  E is F3K title   (generated by drawDashboard)
--  F is for sensor monitoring  (generated by drawDashboard
vbase.horizontaldividery = 115
vbase.verticaldividerx = 280
vbase.f3kDashboardOffset = 143

function vbase.drawDashboard( widget )
	local widget_w, widget_h = lcd.getWindowSize()
	local text_w, text_h = lcd.getTextSize("0")
	local f3kTextOffset = widget_w - vbase.f3kDashboardOffset
	lcd.font(FONT_L)
	if f3kTextOffset > 40 * text_w then   --40 really needs to be investigated
		lcd.color( widget.backgroundcolor )  -- DARKGREY = Gray
		lcd.drawFilledRectangle( f3kTextOffset + 1, 1, widget_w, text_h * 2 + 8 + 8 ) -- 8 pixel empty space at top and bottom
		lcd.color( WHITE )  -- DARKGREY = White
		lcd.drawText( f3kTextOffset + 8, 8, 'F3K', DBLSIZE )
		lcd.drawText( f3kTextOffset + 8, 8 + text_h, 'Training', 0 )
		
		lcd.color(BLACK)
		lcd.drawLine( f3kTextOffset, 0, f3kTextOffset, widget_h )  -- left side outline of f3k logo area
		lcd.drawLine( f3kTextOffset, 8 + 8 + text_h*2, widget_w, 8 + 8+ text_h*2 )  -- bottom side of f3k logo area
		lcd.drawLine( f3kTextOffset, 0, widget_w, 0 ) -- top of f3k logo area
		lcd.drawLine( widget_w, 0, widget_w, 8 + 8 + text_h*2 ) -- bottom of f3k logo area

		lcd.color(WHITE)
		if widget.sensor_battery ~= nil then
			lcd.drawText( f3kTextOffset + 8, text_h*4, "Rx Battery" )
			lcd.drawNumber( f3kTextOffset + 8 + text_w*1, text_h*5, widget.sensor_battery:value(), UNIT_VOLT, 2)
		end
		if widget.sensor_rssi ~= nil then
			lcd.drawText( f3kTextOffset + 8, text_h*7, "Rx RSSI" )
			lcd.drawNumber( f3kTextOffset + 8 + text_w*1, text_h*8, widget.sensor_rssi:value(), UNIT_DB )
		end
	end
end


function vbase.drawCommon( widget, task )
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset

	lcd.font(FONT_XL)
	task.timer1.draw( 115, 44, 0 )

	lcd.color( widget.backgroundcolor )
	-- background rect right side
	lcd.drawFilledRectangle( vbase.verticaldividerx, 0, widget_w - vbase.verticaldividerx, widget_h - 1, 0 )
	-- background rect bottom
	lcd.drawFilledRectangle( 0, vbase.horizontaldividery, vbase.verticaldividerx, widget_h - vbase.horizontaldividery, 0 )
	-- outline left side
	lcd.color(BLACK)
	lcd.drawLine( 0, vbase.horizontaldividery, 0, widget_h, SOLID, 2 )
	-- outline at top of right box
	lcd.drawLine( vbase.verticaldividerx, 0, widget_w, 0, SOLID, 2 )
	-- outline at right side
	lcd.drawLine( widget_w, 0, widget_w, widget_h, SOLID, 2 )
	-- outline at bottom
	lcd.drawLine( 0, widget_h, widget_w, widget_h, SOLID, 2 )

	lcd.drawLine( 0, vbase.horizontaldividery, vbase.verticaldividerx, vbase.horizontaldividery, SOLID, 2 )
	lcd.color(WHITE)
	lcd.font(FONT_L)
	lcd.drawText( 10, 0, task.name, 0 )
	lcd.color(BLACK)
	lcd.drawLine( vbase.verticaldividerx, 0, vbase.verticaldividerx, widget_h - 1, SOLID, 2 )
	
	vbase.drawDashboard( widget )
end


function vbase.drawCommonLastBest( widget, task )
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset
	vbase.drawCommon( widget, task )

	lcd.font(FONT_XL)
	lcd.color(WHITE)
	lcd.drawText( 35, 133, 'Current: ', 0 )
	task.timer2.drawReverse( 170, 133, 0 )
	lcd.font(FONT_L)
	--lcd.color(lcd.RGB(150,0,0)) --FIXME expriment with dark red to see what is being drawn
	--lcd.drawFilledRectangle( 281, 130, widget_w - 281, widget_h - 130, 0 )

	f3kDrawTimer( 312, 153, task.times.getTotal(), 0 )
	lcd.drawText( 312 + 75, 153, "Total", 0 )
	
	vbase.drawDashboard( widget )
end


return vbase
