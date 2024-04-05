--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	WBig/view_b.lua
	Big widget view for the Last Two Flights task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_b.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	if (DebugFunctionCalls) then print("FTRAIN: viewB.display()") end
	vbase.drawCommonLastBest( widget, task )
	vbase.drawImproveMargin( widget, task )
	vbase.drawCurrent( widget, task )
	end

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }

