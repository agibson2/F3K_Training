--[[
	F3K Training - 	Mike, ON4MJ

	X7/view_b.lua
	Q7 view for the Last Two Flights task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_b.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'X7/viewbase.lua' )


function task.display()
	widget.drawCommonLastBest( task )

	if task.state == 4 then
		if task.possibleImprovement > 0 and task.flightCount >= task.COUNT then
			lcd.drawText( 94, 4, 'Improv.', SMLSIZE )
			lcd.drawText( 94, 12, 'margin', SMLSIZE )
			f3kDrawTimer( 98, 22, task.possibleImprovement, 0 )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		lcd.drawText( 96, 13, 'Done !', 0 )
	end

	lcd.drawLine( 90, 32, 127, 32, SOLID, 2 )
	for i=1,task.COUNT do
		task.times.draw( 100, 26 + i*9, i, 0 )
	end

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
