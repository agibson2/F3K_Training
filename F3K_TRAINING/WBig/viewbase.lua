--[[
	F3K Training - 	Mike, ON4MJ

	WBig/viewbase.lua
	Big widget views common stuff
--]]

local widget = {}


function widget.drawCommon( context, task )
	local w = context.zone.w
	local h = context.zone.h
	local horizontaldividery = 115
	local verticaldividerx = 280

	task.timer1.draw( 55, 13, XXLSIZE )

	OpenTX.lcd.setColor( CUSTOM_COLOR, context.options.BackgroundColor )
	-- background rect right side
	OpenTX.lcd.drawFilledRectangle( verticaldividerx, 0, w - verticaldividerx, h - 1, CUSTOM_COLOR )
	-- background rect bottom
	OpenTX.lcd.drawFilledRectangle( 0, horizontaldividery, verticaldividerx, h - horizontaldividery, CUSTOM_COLOR )
	-- outline left side
	OpenTX.lcd.drawLine( 0, horizontaldividery, 0, h, SOLID, 2 )
	-- outline at top of right box
	OpenTX.lcd.drawLine( verticaldividerx, 0, w, 0, SOLID, 2 )
	-- outline at right side
	OpenTX.lcd.drawLine( w, 0, w, h, SOLID, 2 )
	-- outline at bottom
	OpenTX.lcd.drawLine( 0, h, w, h, SOLID, 2 )

	OpenTX.lcd.drawLine( 0, horizontaldividery, verticaldividerx, horizontaldividery, SOLID, 2 )
	OpenTX.lcd.drawText( 10, 133, task.name, 0 )
	OpenTX.lcd.drawLine( verticaldividerx, 0, verticaldividerx, h - 1, SOLID, 2 )
end


function widget.drawCommonLastBest( context, task )
	widget.drawCommon( context, task )

	OpenTX.lcd.drawText( 120, 133, 'Current: ', 0 )
	task.timer2.drawReverse( 200, 129, MIDSIZE )
	
	OpenTX.lcd.drawFilledRectangle( 281, 130, context.zone.w - 281, context.zone.h - 130, TEXT_INVERTED_BGCOLOR )
	f3kDrawTimer( 312, 139, task.times.getTotal(), INVERS )
end


return widget
