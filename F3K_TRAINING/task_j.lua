--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	task_j.lua
	Task J : Last three flight (10 min window)
--]]


local taskJ = dofile( F3K_SCRIPT_PATH .. 'lasttaskbase.lua' )


taskJ.MAX_FLIGHT_TIME = 180
taskJ.COUNT = 3
taskJ.INTRO_LENGTH = 4


-- public interface
function taskJ.init()
	taskJ.possibleImprovement = 0
	taskJ.commonInit( 'Last three', taskJ.COUNT, 'taskj' )
end


return taskJ
