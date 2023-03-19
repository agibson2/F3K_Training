--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	WBig/task_ff.lua
	Big widget view for the Free Flight task
--]]

-- Not working in 2.1.x
--local CLOCK = getFieldInfo( 'clock' ).id


local task = dofile( F3K_SCRIPT_PATH .. 'task_ff.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. FTRAINwidgetresolution .. '/viewbase.lua' )

function task.display( widget )
	if (DebugFunctionCalls) then print("FTRAIN: ff_display()") end

	vbase.drawCommon( widget, task )
	vbase.drawPrepWorkTime( widget, task )
	vbase.drawCurrent( widget, task )
	vbase.drawTimes( widget, task )

	lcd.font(FONT_L)
	local text_w, text_h = lcd.getTextSize("0")
	for i=0,task.COUNT - 1 do
		if widget.launch_height_enabled then
			task.heights.drawUnit( vbase.verticaldividerx + (text_w*11), 3 + text_h*i, i+1, widget.sensor_altitude:unit(), 0, 0 )
		end
	end
	
	vbase.drawDashboard( widget, task )
	return task.background(widget)
end


return { init=task.init, background=task.background, display=task.display }
