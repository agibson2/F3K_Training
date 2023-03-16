--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_a.lua
	Big widget view for the Last Flight task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_a.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	if (DebugFunctionCalls) then print("FTRAIN: viewA.display()") end
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset  -- exclude right side for dashboard
	vbase.drawCommonLastBest( widget, task )
	if task.shoutedStop or task.timer1.getVal() <= 0 then
		vbase.drawDone( widget, task )
	else
		vbase.drawCurrent( widget, task )
		vbase.drawImproveMargin( widget, task )
	end
	
	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
