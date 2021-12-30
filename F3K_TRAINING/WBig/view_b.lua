--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_b.lua
	Big widget view for the Last Two Flights task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_b.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( context )
	widget.drawCommonLastBest( context, task )

	if task.state == 4 then
		if task.possibleImprovement > 0 and task.flightCount >= task.COUNT then
			OpenTX.lcd.drawText( 300, 12, 'Improve', 0 )
			OpenTX.lcd.drawText( 305, 30, 'margin', 0 )
			f3kDrawTimer( 300, 55, task.possibleImprovement, MIDSIZE )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		OpenTX.lcd.drawText( 305, 25, 'Done !', MIDSIZE )
	end

	OpenTX.lcd.drawLine( 280, 82, context.zone.w, 82, SOLID, 2 )
	for i=1,task.COUNT do
		task.times.draw( 312, 70 + 16*i, i, 0 )
	end

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }

