--[[
	F3K Training - 	Mike, ON4MJ

	X9/view_b.lua
	Taranis view for the Last Two Flights task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_b.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'X9/viewbase.lua' )


function task.display()
	widget.drawCommonLastBest( task )

	if task.state == 4 then
		if task.possibleImprovement > 0 and task.flightCount >= task.COUNT then
			lcd.drawText( 166, 2, 'Improve', 0 )
			lcd.drawText( 168, 12, 'margin', 0 )
			f3kDrawTimer( 172, 20, task.possibleImprovement, MIDSIZE )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		lcd.drawText( 166, 10, 'Done !', MIDSIZE )
	end

	lcd.drawLine( 159, 32, 211, 32, SOLID, 2 )
	for i=1,task.COUNT do
		task.times.draw( 180, 26 + i*9, i, 0 )
	end

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
