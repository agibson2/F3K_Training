--[[
	F3K Training - 	Mike, ON4MJ

	X7/view_a.lua
	Q7 view for the Last Flight task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_a.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X7/viewbase.lua' )


function task.display()
	display.drawCommonLastBest( task )

	if task.state == 4 then	-- landed
		if task.possibleImprovement > 0 then
			lcd.drawText( 94, 4, 'Improv.', SMLSIZE )
			lcd.drawText( 94, 14, 'margin', SMLSIZE )
			f3kDrawTimer( 98, 26, task.possibleImprovement, 0 )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		lcd.drawText( 96, 18, 'Done !', 0 )
	end

	lcd.drawLine( 90, 41, 127, 41, SOLID, 2 )
	task.times.draw( 100, 44, 1, 0 )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
