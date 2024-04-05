--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	WBig/view_j.lua
	Big widget view for the Last Three task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_j.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	vbase.drawCommonLastBest( widget, task )
	vbase.drawImproveMargin( widget, task )
	vbase.drawCurrent( widget, task )

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
