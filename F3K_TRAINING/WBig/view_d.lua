--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	view_d.lua
	Task D : Two Flights (10 min window)
	Each competitor has two (2) flights. These two flights will be added together. The maximum accounted single flight time is 300 seconds. Working time is 10 minutes.
--]]


--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	view_d.lua
	Task D : Two Flights (10 min window)
	Each competitor has two (2) flights. These two flights will be added together. The maximum accounted single flight time is 300 seconds. Working time is 10 minutes.
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_d.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )

	display.drawCommon( widget, task )

	lcd.color(WHITE)
	if not task.done then
	lcd.font(FONT_XL)
		lcd.drawText( 35, 133, 'Current: ' )
		task.timer2.drawReverse( 170, 133, 0 )
	else
		lcd.font(FONT_L)
		lcd.drawText( 312, 53, 'Done !' )
	end

	lcd.font(FONT_L)
	local text_w, text_h = lcd.getTextSize("A")
	local total = 0
	for i=0,1 do
	--print("i : " .. i)
		local y = text_h * i
		local max = 300
		lcd.drawText( 312, y, '5min' )

		if i < task.current - 1 then
		--print (4-task.current+i)
			local val = task.times.getVal( 4-task.current+i )
			--local val = task.times.getVal( 2 + 1 * i )
			
			--print (val)
			f3kDrawTimer( 400, y, val, 0 )
			total = total + math.min( max, val )
		else
			local text_w_timer, text_h_timer = lcd.getTextSize("00:00")
			lcd.drawText( 400 + text_w_timer/2, y, "--:--", CENTERED )
		end
	end

	--lcd.drawFilledRectangle( 160, 47, 52, 18, 0 )
	f3kDrawTimer( 312, text_h * 4, total, 0 )
	lcd.drawText( 390, text_h * 4, "Total" )

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
