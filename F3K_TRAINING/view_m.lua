--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_m.lua
	Fly-off Task M (Increasing time by 2 minutes “Huge Ladder”)
    Each competitor must launch his/her model glider exactly three (3) times to achieve three (3) target times as follows: 3:00 (180 seconds), 5:00 (300 seconds), 7:00 (420 seconds). The targets must be flown in the increasing order as specified. The actual times of each flight up to (not exceeding) the target time will be added up and used as the final score for the task. The competitors do not have to reach or exceed the target times to count each flight time.
    Working time: 15 minutes.
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_m.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display(widget)
	vbase.drawCommon( widget, task )

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
