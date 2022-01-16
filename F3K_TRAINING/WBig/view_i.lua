--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_i.lua
	Big widget view for the Best Three task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_i.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	local widget_w, widget_h = lcd.getWindowSize()
	vbase.drawCommonLastBest( widget, task )

	if task.state == 4 and task.times.getVal( task.BEST_COUNT ) >= task.timer1.getVal() then
		lcd.drawText( 305, 12, 'Done !' )
	end
	lcd.drawLine( 280, 54, widget_w - 1, 54, SOLID, 2 )

	local text_w, text_h = lcd.getTextSize("")
	local y = text_h
	for i=0,2 do
		task.times.draw( 312, y + text_h*i, i+1, 0 )
	end

	return task.background( widget )
end



return { init=task.init, background=task.background, display=task.display }
