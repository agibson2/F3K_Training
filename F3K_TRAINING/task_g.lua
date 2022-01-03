--[[
	F3K Training - 	Mike, ON4MJ

	task_g.lua
	Task G : 5X2 (10 min window)
--]]


local taskG = dofile( F3K_SCRIPT_PATH .. 'besttaskbase.lua' )


taskG.MAX_FLIGHT_TIME = 120
taskG.BEST_COUNT = 5


-- public interface
function taskG.init()
	taskG.commonInit( '5x2', taskG.BEST_COUNT, 'taskg' )
	taskG.timer1.stop()
	taskG.timer2.stop()
end


return taskG
