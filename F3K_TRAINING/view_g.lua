--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	WBig/view_g.lua
	Big widget view for the 5x2 task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_g.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	
	vbase.drawCommonLastBest( widget, task )

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		vbase.drawDone( widget, task )
	else
		vbase.drawCurrent( widget, task )
	end

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
