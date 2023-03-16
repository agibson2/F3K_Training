--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_c.lua
	Big widget view for the AULD task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_c.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	vbase.drawCommonAULD( widget, task )
	if task.state == 5 then
		vbase.drawDone( widget, task )
	end

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
