--[[
	F3K Training - 	Mike, ON4MJ

	custom.lua
	This file is meant to contain the things which can be customized by the user
	See the documentation
--]]


local SOUND_PATH = F3K_SCRIPT_PATH .. 'sounds/'

local lastTimeLanded = 0	-- 0=must pull first ; other=time of the last pull

local function resetLaunchDetection()
	lastTimeLanded = 0
end

-- >>> Launch / Land detection <<< ---
local function launched()
	if not widget.prelaunchswitch then
		return
	end

	local ret = false
	if widget.prelaunchswitch:getValue() < 0 then
		-- if the tmp switch is held for more than 0.6s, it's a launch ;
		-- otherwise it was just a trigger pull to indicate that the plane has landed
		if lastTimeLanded > 0 then
			if (os.clock() - lastTimeLanded) > 0.060 then
				ret = true
			end
			lastTimeLanded = 0
		end
	else
		if lastTimeLanded == 0 then
			lastTimeLanded = os.clock()
		end
	end
	return ret
end

local function landed()
	if not widget.prelaunchswitch then
		return
	end
	if widget.prelaunchswitch:getValue() > 0 then
		lastTimeLanded = os.clock()
		return true
	end
	return false
end
-- <<< End of launch/land detection section <<< --


--[[
	-- Alternate implementation of the launched / landed logic through traditional Tx programmation
	-- 	* Logical switch LS31 would be "launch detected"
	-- 	* Logical switch LS32 would be "landing detected"

local function launched()
	return getValue( 'ls31' ) > 0
end

local function landed()
	return getValue( 'ls32' ) > 0
end	
--]]



return { 
	BGCOLOR_R = 200,
	BGCOLOR_G = 200,
	BGCOLOR_B = 200,
	SOUND_PATH = SOUND_PATH,


	resetLaunchDetection = resetLaunchDetection,
	launched = launched,
	landed = landed
}
