--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	view_d.lua
	Task D : Two Flights (10 min window)
	Each competitor has two (2) flights. These two flights will be added together. The maximum accounted single flight time is 300 seconds. Working time is 10 minutes.
--]]


--[[
	F3K Training - 	CIRRUS_RC   08 Mar 2020

	view_d.lua
	Task D : Two Flights (10 min window)
	Each competitor has two (2) flights. These two flights will be added together. The maximum accounted single flight time is 300 seconds. Working time is 10 minutes.
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_d.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )


function task.display( widget )

	vbase.drawCommon( widget, task )
	vbase.drawPrepWorkTime( widget, task )

	if not task.done then
		vbase.drawCurrent( widget, task )
	else
		vbase.drawDone( widget, task )  --lcd.drawText( 312, 53, 'Done !' )
	end
--
	vbase.drawTimes( widget, task )
	vbase.drawTimesTotal( widget, task )
	vbase.drawNote( widget, "(5min max)" )

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
