--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_i.lua
	Big widget view for the Best Three task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_i.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )
	vbase.drawCommonLastBest( widget, task )

	if task.state == 4 and task.times.getVal( task.COUNT ) >= task.timer1.getVal() then
		vbase.drawDone( widget, task )
	else
		vbase.drawCurrent( widget, task )
	end

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
