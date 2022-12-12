--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	view_l.lua
	Task L : One Flight only (10 min window)
	During the working time, the competitor may launch his model glider one single time. The maximum flight time is limited to 599 seconds (9 minutes 59 seconds).  Working time: 10 minutes.
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_l.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display(widget)
	display.drawCommon( widget, task )
	lcd.font(FONT_XL)
	lcd.color(WHITE)
	if not task.done then
		lcd.drawText( 10, 133, 'Current: ' )
		task.timer2.drawReverse(100, 183, 0 )
	else
		lcd.drawText( 95, 133, 'Done !' )
	end

	local text_w, text_h = lcd.getTextSize("0")
	local total = 0
	local text959 = "9:59"
	local text959_w, text959_y = lcd.getTextSize(text959)
	for i=0,0 do
	--print("i : " .. i)
		local y = 15 + text_h * i
		local max = 300
		lcd.drawText( 303, y, text959 )

		if i < task.current - 1 then
		--print (4-task.current+i)
			local val = task.times.getVal( 3-task.current+i )
			
			--print (val)
			f3kDrawTimer( 303 + text959_w + text_w, y, val, 0 )
			total = total + math.min( max, val )
		else
			local text_w_timer, text_h_timer = lcd.getTextSize("00:00")
			lcd.drawText( 303 + text959_w + text_w + (text_w_timer/2), y, "--:--", CENTERED )
		end
	end

	--lcd.drawFilledRectangle( 160, 47, 52, 18, 0 )
	lcd.font(FONT_XL)
	f3kDrawTimer( 303, text_h*3, total )
	lcd.drawText( 391, text_h*3, "Total" )

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }