--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_f.lua
	Big widget view for the Three Out Of Six task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_f.lua' )
local vbase = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( widget )
	--local horizontaldividery = 115
	--local verticaldividerx = 280
	local widget_w, widget_h = lcd.getWindowSize()
	
	vbase.drawCommon( widget, task )
	lcd.color(WHITE)
	
	if task.wellDone or (task.flightCount == 6 and task.state ~= 3) then
		lcd.drawText( 104, 133, 'Done !', 0 )
	else
		lcd.drawText( 38, 133, 'Flight #', 0 )
		--lcd.drawText( 112, 133, '#', 0 )
		lcd.drawText( 124, 133, tostring( math.max( 1, task.flightCount ) ), 0 )
		lcd.drawText( 139, 133, ': ', 0 )
		task.timer2.drawReverse( 160, 133, 0 )
	end

	for i=0,5 do
		task.times.draw( 312, 5 + 21*i, i+1, 0 )
	end
	--lcd.color(lcd.RGB(40,40,40))
	--lcd.drawFilledRectangle( verticaldividerx + 1, 139, widget_w - verticaldividerx + 1, widget_h - 139, 0 )  -- was inverted background color
	--lcd.color(WHITE)
	f3kDrawTimer( 312, 145, task.times.getTotal( 3 ), 0 )
	lcd.drawText( 390, 145, "Total", 0 )

	return task.background( widget )
end


return { init=task.init, background=task.background, display=task.display }
