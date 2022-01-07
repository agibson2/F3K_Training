--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_k.lua
	Taranis view for the Big Ladder practice task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_k.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	local widget_w, widget_h = lcd.getWindowSize()
	local text_w, text_h = lcd.getTextSize("A")
	display.drawCommon( widget, task )

	lcd.color(WHITE)
	if not task.done then
		lcd.font(FONT_XL)
		lcd.drawText( 123, 133, task.MAX_FLIGHT_TIME .. 's: ', RIGHT )
		task.timer2.drawReverse( 143, 133, 0 )
		lcd.font(FONT_L)
	else
		lcd.drawText( 113, 140, 'Done !', 0 )
	end

	local total = 0
	for i=0,4 do
	--print("i : " .. i)
		local y = text_h * i
		local max = 60 + 30 * i
		--local textlength, textheight = lcd.getTextSize(tostring(max))
		lcd.drawNumber( 333, y, max, UNIT_SECONDS, 0, RIGHT ) -- RIGHT justification doesn't work yet in Ethos so use workaround in above line
		lcd.drawText( 333, y, 's', 0 )

		if i < task.current - 1 then
		--print (7-task.current+i)
			local val = task.times.getVal( 7-task.current+i )
			--local val = task.times.getVal( 2 + 1 * i )
			
			--print (val)
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
