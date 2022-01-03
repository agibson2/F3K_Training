--[[
	F3K Training - 	Mike, ON4MJ

	WBig/viewbase.lua
	Big widget views common stuff
--]]

local vbase = {}


function vbase.drawCommon( widget, task )
	local widget_w, widget_h = lcd.getWindowSize()
	local horizontaldividery = 115
	local verticaldividerx = 280

	lcd.font(FONT_XL)
	task.timer1.draw( 115, 44, 0 )

	lcd.color( widget.backgroundcolor )
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
	lcd.color(WHITE)
	lcd.font(FONT_L)
	lcd.drawText( 10, 0, task.name, 0 )
	lcd.color(BLACK)
	lcd.drawLine( verticaldividerx, 0, verticaldividerx, widget_h - 1, SOLID, 2 )
end


function vbase.drawCommonLastBest( widget, task )
	local widget_w, widget_h = lcd.getWindowSize()
	vbase.drawCommon( widget, task )

	lcd.font(FONT_L)
	lcd.color(WHITE)
	lcd.drawText( 85, 133, 'Current: ', 0 )
	task.timer2.drawReverse( 200, 133, 0 )
	lcd.color(150,0,0) --FIXME expriment with dark red to see what is being drawn
	lcd.drawFilledRectangle( 281, 130, widget_w - 281, widget_h - 130, 0 )
	lcd.color(WHITE)
	f3kDrawTimer( 312, 153, task.times.getTotal(), 0 )
	lcd.drawText( 312 + 75, 153, "Total", 0 )
end


return vbase
