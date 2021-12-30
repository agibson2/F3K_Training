--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_ff.lua
	Taranis view for the Free flight task
--]]

-- Not working in 2.1.x
--local CLOCK = getFieldInfo( 'clock' ).id


local task = dofile( F3K_SCRIPT_PATH .. 'task_ff.lua' )


function task.display()
	task.timer1.draw( 24, 4, XXLSIZE )
	task.timer2.draw( 80, 53, 0 )
	f3kDrawTimer( 120, 53, getValue( 'clock' ), 0 )

	lcd.drawLine( 0, 47, 159, 47, SOLID, 2 )
	lcd.drawText( 2, 53, task.name, 0 )
	lcd.drawLine( 159, 0, 159, 63, SOLID, 2 )

	local y = 1
	for i=0,7 do
		task.times.draw( 180, y + 9*i, i+4, 0 )
	end

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
