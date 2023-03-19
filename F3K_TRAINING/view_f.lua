--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	WBig/view_f.lua
	Big widget view for the Three Out Of Six task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_f.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	vbase.drawCommonLastBest( widget, task )
	
	if task.wellDone or (task.flightCount == 6 and task.state ~= 3) then
		vbase.drawDone( widget, task )
	else
		vbase.drawCurrent( widget, task )
	end

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
