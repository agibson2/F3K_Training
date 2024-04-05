--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	WBig/view_c.lua
	Big widget view for the AULD task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_c.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	vbase.drawCommonAULD( widget, task )
	vbase.drawPrepWorkTime( widget, task )

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
