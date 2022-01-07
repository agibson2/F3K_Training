--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_a.lua
	Big widget view for the Last Flight task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_a.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	if (DebugFunctionCalls) then print("FTRAIN: viewA.display()") end
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset  -- exclude right side for dashboard
	vbase.drawCommonLastBest( widget, task )

	if task.state == 4 then	-- landed
		if task.possibleImprovement > 0 then
			lcd.drawText( 300, 12, 'Improve margin', 0 )
			f3kDrawTimer( 350, 55, task.possibleImprovement, 0 )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		lcd.drawText( 305, 25, 'Done !', 0 )
	end

	task.times.draw( 312, 98, 1, 0 )
	lcd.color(BLACK)
	lcd.drawLine( vbase.verticaldividerx, 90, widget_w - 1, 90, SOLID, 2 )
	
	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
