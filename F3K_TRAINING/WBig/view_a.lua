--[[
	F3K Training - 	Mike, ON4MJ

	WBig/view_a.lua
	Big widget view for the Last Flight task
--]]


local task = dofile( F3K_SCRIPT_PATH .. 'task_a.lua' )
local widget = dofile( F3K_SCRIPT_PATH .. 'WBig/viewbase.lua' )


function task.display( context )
	widget.drawCommonLastBest( context, task )

	if task.state == 4 then	-- landed
		if task.possibleImprovement > 0 then
			OpenTX.lcd.drawText( 300, 12, 'Improve', 0 )
			OpenTX.lcd.drawText( 305, 30, 'margin', 0 )
			f3kDrawTimer( 300, 55, task.possibleImprovement, MIDSIZE )
		end
	end

	if task.shoutedStop or task.timer1.getVal() <= 0 then
		OpenTX.lcd.drawText( 305, 25, 'Done !', MIDSIZE )
	end

	OpenTX.lcd.drawLine( 280, 90, context.zone.w - 1, 90, SOLID, 2 )
	task.times.draw( 312, 98, 1, 0 )

	return OpenTX.backgroundRun( task )
end


return { init=task.init, background=task.background, display=task.display }
