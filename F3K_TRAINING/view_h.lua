--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_h.lua
	Big widget view for the 1234 task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_h.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset  -- exclude right side for dashboard
	vbase.drawCommon( widget, task )

	if task.done then
		vbase.drawDone( widget, task )
	else
		vbase.drawCurrent( widget, task )
	end
	
	vbase.drawTimes( widget, task )
	vbase.drawTimesTotal( widget, task )
	vbase.drawPrepWorkTime( widget, task )
	vbase.drawCurrent( widget, task )

	lcd.font(FONT_L)
	local text_w, text_h = lcd.getTextSize("0")
	local check = task.getDoneList()

	lcd.color(WHITE)

	local y = 3
	local total = 0
	local drawcount = 0
	for i=4,1,-1 do

		local ri = 5 - i
		if check[ i ] then
			lcd.color(GREEN)
		else
			lcd.color(BLACK)
		end

		local topleftx = widget_w - 3 - (text_w * 2)
		lcd.drawFilledRectangle( topleftx - text_w, y, text_w * 3, text_h )

		lcd.color(WHITE)
		if check[ i ] then
			lcd.color(BLACK)
		else
			lcd.color(WHITE)
		end
		lcd.drawText( topleftx, y, tostring( i ) )

		total = total + math.min( i*60, task.times.getVal( ri ) )
		y = y + text_h
		drawcount = drawcount + 1
	end

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
