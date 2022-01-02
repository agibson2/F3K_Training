--[[
	F3K Training - 	Mike, ON4MJ

	task_a.lua
	Task A : Last flight (7 - 10 min window)
--]]


local taskA = dofile( F3K_SCRIPT_PATH .. 'lasttaskbase.lua' )


taskA.MAX_FLIGHT_TIME = 300
taskA.COUNT = 1


-- public interface
function taskA.init( win )
	if (DebugFunctionCalls) then print("FTRAIN: taskA.init()") end
	taskA.WINDOW_TIME = win
	taskA.commonInit( 'Last Flight', taskA.COUNT, 'taska' )
end


return taskA
