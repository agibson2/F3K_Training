--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	view_l.lua
	Task L : One Flight only (10 min window)
	During the working time, the competitor may launch his model glider one single time. The maximum flight time is limited to 599 seconds (9 minutes 59 seconds).  Working time: 10 minutes.
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_l.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display(widget)
	vbase.drawCommon( widget, task )
	vbase.drawPrepWorkTime( widget, task )

	if not task.done then
		vbase.drawCurrent( widget, task )
	else
		vbase.drawDone( widget, task )
	end
--
	vbase.drawTimes( widget, task )
	vbase.drawTimesTotal( widget, task )

	vbase.drawNote( widget, "(9:59 max)" )

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }