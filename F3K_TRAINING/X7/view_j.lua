--[[
	F3K Training - 	Mike, ON4MJ

	X7/view_j.lua
	Q7 view for the Last Three task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_j.lua' )
local display = dofile( F3K_SCRIPT_PATH .. 'X7/viewbase.lua' )


function task.display()
	display.drawCommonLastBest( task )

	--if task.state == 4 then
	--	if task.possibleImprovement > 0 and task.flightCount >= task.COUNT then
			lcd.drawText( 95, 1, 'Margin', SMLSIZE )
			f3kDrawTimer( 95, 10, task.possibleImprovement, MIDSIZE )
	--	end
	--end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		lcd.drawText( 95, 7, 'Done !', BOLD )
	end

	lcd.drawLine( 91, 23, 127, 23, SOLID, 2 )
	for i=1,task.COUNT do
		task.times.draw( 100, 17 + i*9, i, 0 )
	end

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
