--[[
	F3K Training - 	Mike, ON4MJ

	task_b.lua
	Task B : Last two flights (7 or 10 min window)
--]]


local taskB = dofile( F3K_SCRIPT_PATH .. 'lasttaskbase.lua' )


taskB.MAX_FLIGHT_TIME = 240
taskB.COUNT = 2


-- public interface
function taskB.init( win )
	local wav = 'taskb'
	taskB.WINDOW_TIME = win
	if win == 420 then
		taskB.MAX_FLIGHT_TIME = 180
		wav = wav .. '7'
	end
	taskB.commonInit( 'Last two', taskB.COUNT, wav )
	taskB.timer1.stop()
	taskB.timer2.stop()
end


return taskB
