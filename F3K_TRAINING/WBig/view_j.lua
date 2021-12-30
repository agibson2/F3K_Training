--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_j.lua
	Big widget view for the Last Three task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_j.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( context )
	widget.drawCommonLastBest( context, task )

	if task.state == 4 then
		if task.possibleImprovement > 0 and task.flightCount >= task.COUNT then
			OpenTX.lcd.drawText( 296, 3, 'Impr. Mrg.', 0 )
			f3kDrawTimer( 304, 27, task.possibleImprovement, MIDSIZE )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		OpenTX.lcd.drawText( 305, 16, 'Done !', MIDSIZE )
	end

	OpenTX.lcd.drawLine( 280, 62, context.zone.w - 1, 62, SOLID, 2 )
	for i=1,task.COUNT do
		task.times.draw( 312, 44 + 21*i, i, 0 )
	end

	return OpenTX.backgroundRun( task )
end

return { init=task.init, background=task.background, display=task.display }
