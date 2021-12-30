--[[
	F3K Training - 	Mike, ON4MJ

	X7/view_ff.lua
	Q7 view for the Free flight task
--]]

-- Not working in 2.1.x
--local CLOCK = getFieldInfo( 'clock' ).id


local task = dofile( F3K_SCRIPT_PATH .. 'task_ff.lua' )


function task.display()
	lcd.drawText( 2, 2, task.name, 0 )

	task.timer1.draw( 24, 18, DBLSIZE )
	task.timer2.draw( 10, 53, 0 )
	f3kDrawTimer( 50, 53, getValue( 'clock' ), 0 )

	lcd.drawLine( 0, 47, 89, 47, SOLID, 2 )
	lcd.drawLine( 90, 0, 90, 63, SOLID, 2 )

	local y = 1
	for i=0,7 do
		task.times.draw( 100, y + 9*i, i+4, 0 )
	end

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
