--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	task_n.lua
	Task N : Best flight (10 min window)
--]]


local taskN = dofile( F3K_SCRIPT_PATH .. 'besttaskbase.lua' )


taskN.MAX_FLIGHT_TIME = 599
taskN.COUNT = 1
taskN.INTRO_LENGTH = 5


-- public interface
function taskN.init()
	taskN.commonInit( 'Best flight', taskN.COUNT, 'taskn' )
end


return taskN