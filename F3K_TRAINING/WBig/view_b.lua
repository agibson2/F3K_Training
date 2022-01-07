--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_b.lua
	Big widget view for the Last Two Flights task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_b.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	if (DebugFunctionCalls) then print("FTRAIN: viewB.display()") end
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset  -- exclude right side for dashboard
	vbase.drawCommonLastBest( widget, task )

	if task.state == 4 then
		if task.possibleImprovement > 0 and task.flightCount >= task.COUNT then
			lcd.drawText( 300, 12, 'Improve margin', 0 )
			f3kDrawTimer( 350, 55, task.possibleImprovement, 0 )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		lcd.drawText( 305, 25, 'Done !', 0 )
	end

	lcd.color(BLACK)
	lcd.drawLine( 280, 82, widget_w, 82, SOLID, 2 )
	lcd.color(WHITE)
	local text_w, text_h = lcd.getTextSize("")
	for i=1,task.COUNT do
		task.times.draw( 312, 70 + text_h*i, i, 0 )
	end

	return task.background(widget)
end


return { init=task.init, background=task.background, display=task.display }

