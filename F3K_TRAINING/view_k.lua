--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	WBig/view_k.lua
	Taranis view for the Big Ladder practice task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_k.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display(widget)
	vbase.drawCommon( widget, task )
	vbase.drawPrepWorkTime( widget, task )
	
	if not task.done then
		vbase.drawTargetCurrent( widget, task )
	else
		vbase.drawDone( widget, task )
	end

	vbase.drawTargetList( widget, task )

	vbase.drawTimes( widget, task )
	vbase.drawTimesTotal( widget, task )

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
