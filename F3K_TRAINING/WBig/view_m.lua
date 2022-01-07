--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_m.lua
	Fly-off Task M (Increasing time by 2 minutes “Huge Ladder”)
    Each competitor must launch his/her model glider exactly three (3) times to achieve three (3) target times as follows: 3:00 (180 seconds), 5:00 (300 seconds), 7:00 (420 seconds). The targets must be flown in the increasing order as specified. The actual times of each flight up to (not exceeding) the target time will be added up and used as the final score for the task. The competitors do not have to reach or exceed the target times to count each flight time.
    Working time: 15 minutes.
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_m.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display(widget)
	local widget_w, widget_h = lcd.getWindowSize()
	local text_w, text_h = lcd.getTextSize("A")
	vbase.drawCommon( widget, task )

	print("FTRAIN: TEST 1")
	lcd.color(WHITE)
	if not task.done then
		lcd.font(FONT_XL)
		lcd.drawText( 123, 133, task.MAX_FLIGHT_TIME .. 's: ', RIGHT )
		task.timer2.drawReverse( 143, 133, 0 )
		lcd.font(FONT_L)
	else
		lcd.drawText( 113, 140, 'Done !', 0 )
	end

	print("FTRAIN: TEST 2")

	local total = 0
	for i=0,2 do
		--print("i : " .. i)
		local y = 8 + text_h * i
		local max = 180 + 120 * i
		lcd.drawNumber( 333, y, max, UNIT_SECONDS, 0, RIGHT )
		lcd.drawText( 333, y, 's', 0 )
		if i < task.current - 1 then
		--print (5-task.current+i)
			local val = task.times.getVal( 5-task.current+i )
			--print( val )
			f3kDrawTimer( 333+text_w*2, y, val, 0 )
			total = total + math.min( max, val )
		else
			local text_w_timer, text_h_timer = lcd.getTextSize("00:00")
			lcd.drawText( 333+text_w*2 + text_w_timer/2, y, "--:--", CENTERED )
		end
	end

	--lcd.drawFilledRectangle( 160, 47, 52, 18, 0 )
	f3kDrawTimer( 295, 133, total, 0 )  -- was bold and inverted text
	lcd.drawText( 370, 133, "Total", 0 )

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
