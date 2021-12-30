--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_a.lua
	Taranis view for the Last Flight task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_a.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X9/viewbase.lua' )


function task.display()
	display.drawCommonLastBest( task )

	if task.state == 4 then	-- landed
		if task.possibleImprovement > 0 then
			lcd.drawText( 166, 4, 'Improve', 0 )
			lcd.drawText( 168, 14, 'margin', 0 )
			f3kDrawTimer( 172, 25, task.possibleImprovement, MIDSIZE )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		lcd.drawText( 166, 14, 'Done !', MIDSIZE )
	end

	lcd.drawLine( 159, 41, 211, 41, SOLID, 2 )
	task.times.draw( 180, 44, 1, 0 )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
