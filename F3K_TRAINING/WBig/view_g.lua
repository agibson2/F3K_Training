--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_g.lua
	Big widget view for the 5x2 task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_g.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	
	vbase.drawCommonLastBest( widget, task )

	if task.state == 4 and task.times.getVal( task.BEST_COUNT ) >= task.timer1.getVal() then
		lcd.drawText( 110, 84, 'Done !', 0 )
	end
	
	local text_w, text_h = lcd.getTextSize("")
	for i=0,4 do
		task.times.draw( 312, 10 + text_h*i, i+1, 0 )
	end

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
