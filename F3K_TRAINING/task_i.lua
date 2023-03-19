--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	task_i.lua
	Task I : Best Three (10 min window)
--]]


local taskI = dofile( F3K_SCRIPT_PATH .. 'besttaskbase.lua' )


taskI.MAX_FLIGHT_TIME = 200
taskI.COUNT = 3


-- public interface
function taskI.init()
	taskI.commonInit( 'Best three', taskI.COUNT, 'taski' )
end


return taskI