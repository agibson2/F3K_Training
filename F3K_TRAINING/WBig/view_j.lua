--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_j.lua
	Big widget view for the Last Three task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_j.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	local widget_w, widget_h = lcd.getWindowSize()
	local text_w, text_h = lcd.getTextSize("")
	vbase.drawCommonLastBest( widget, task )

	if task.state == 4 then
		if task.possibleImprovement > 0 and task.flightCount >= task.COUNT then
			lcd.drawText( 296, 3, 'Improve margin', 0 )
			f3kDrawTimer( 304, text_h + 3, task.possibleImprovement, 0 )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		lcd.drawText( 305, 16, 'Done !', 0 )
	end
	
	lcd.color(BLACK)
	lcd.drawLine( 280, 62, widget_w - 1, 62, SOLID, 2 )

	lcd.color(WHITE)	
	for i=1,task.COUNT do
		task.times.draw( 312, 44 + text_h*i, i, 0 )
	end

	return task.background( widget )
end

return { init=task.init, background=task.background, display=task.display }
