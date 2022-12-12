F3KVersion = '4.1.2'
--[[
	F3K Training - 	Mike, ON4MJ
	(Ethos conversion by StatiC on RCGroups)

	telemN.lua
	Main script (provides the UI and loads the relevant task script)

	This is a telemetry script
	REQUIRES Ethos 1.1.0 or newer

	Provides a serie of specialized timer screens for most F3K tasks
	NB: there's no telemetry at all in this "telemetry" script.

	Releases
	0.9 	Initial release (incorrectly labeled as 1.0 at the time)
	1.0 	Skipped to avoid confusion
	1.01 	Added the preparation time
		Reduced the temp switch hold time to 0.75s
		The short window time was not initialized with a default value
		Better support of custom launch detection functions
	1.02	2.0.15 support : reduced the memory footprint (the short window option had to go, sorry about that)
		When running the "last" tasks several times in a row, the "improve margin"
			message could stay on screen at the beginning of the subsequent tasks
		When running "ladder" several times in a row, the flight timer was not reset
		In last 2&3, you won't be congratulated for maxing a single flight anymore; only for maxing the task
		Added congratulations to 3oo6
		Corrected the initial display of 1234
		Reduced the usage of setTimer(), which seems to write in the eeprom !! 
			(so, probably improved the life expectancy of the TX)
		Reduced the temporary switch holding time again

	2.00	Major refactoring: split the original script in several dynamically loaded files 
			to get rid of all those memory problems
		Added Task M
		Correction of a false launch detection problem when the previous task was "Done !"
	2.01	Fixed a regression introduced in 2.0 which caused the script to crash in several tasks 
			when the plane was still flying at the end of the working time
	2.02	Added a quick turnaround practice task
	2.03	Added variations with a 7-min work time in task A & B
		OpenTX 2.1.x compatibility (not tested on the transmitter)
	2.04	Added a "Free Flight" non-task, which provides a normal usage of the timers
		Added the total flight time to the QT practice
	2.05	Changed the QT practice to count down from 30s
		Solved some OpenTX 2.0 vs. 2.1 incompatibilities
	2.06    StatiC (Adam) - Imlemented Horus compatibility for large Widget size.  Other widget sizes will not display properly.
			Allow persistent storage of options if run as a Widget (options storage is a feature of Widgets).

	3.00	Refactoring again : separated the views from the domain.  
		The goal was to go multi-platform : Q7 and Horus (large for now) Widgets support
		Added 2.2 compatibility for the Taranis
	3.01	Horus widget fix : browsing through widgets to install a new one in another zone broke an already installed Training widget.
	3.02	Added AULD
		Fixed a regression introduced in 3.00 where a false launch could be detected when running the same task more than once
	4.0.0 alpha 1 - StatiC (Adam)
	      Major Ethos changes which removes OpenTX compatibility
		  Task Free Flight and TaskA are working
		  Task B working
		  Tasks C D E F G H I J K working
	4.0.1 First release
		  All tasks working
		  Cleanup of code and remove old files that were only needed for OpenTX
		  Fixed Done text for TaskH
	4.1.0 Added launch height detection for Free Flight task.  Need to configure altitude and vspeed sensors in widget config.
		  Added list of launch height history to go along with times
	4.1.1 Changed Free Flight task to show session time at top left and current flight at bottom left to be consistent with other tasks
	4.1.2 Added zeroing of Altitude for configured altitude sensor when pressing prelaunch switch
--]]

local FTRAINDebug=0

DebugFunctionCalls=false
DebugInvalidateWindow=false
DebugConfig=false
DebugMenu=false
DebugLaunched=false
DebugLanded=false
DebugTimes=false
DebugTimers=false
DebugLaunchHeight=false

if(FTRAINDebug >= 1) then
	DebugInvalidateWindow=true
	--DebugConfig=true
end
if(FTRAINDebug >= 2) then
	DebugFunctionCalls=true
	DebugLaunched=true
	DebugLanded=true
end
if(FTRAINDebug >= 3) then
	--DebugMenu=true
end


local lastTimeLanded = 0	-- 0=must pull first ; other=time of the last pull
local prelaunchpressed = false

function resetLaunchDetection()
	lastTimeLanded = 0
end

-- >>> Launch / Land detection <<< ---
function f3klaunched(widget)
	local ret = false
	if not widget.prelaunchswitch:state() then
		-- if the tmp switch is held for more than 0.6s, it's a launch ;
		-- otherwise it was just a trigger pull to indicate that the plane has landed		
		if lastTimeLanded > 0 then
			if (DebugLaunched) then print("FTRAIN: f3klaunched() lastTimeLanded > 0 os.clock()=" .. os.clock() .. " lastTimeLanded=" .. lastTimeLanded .. " difference=" .. os.clock() - lastTimeLanded) end
			if (os.clock() - lastTimeLanded) > 0.6 then   -- 600 milliseconds
				ret = true
			end
			lastTimeLanded = 0
		end
		prelaunchpressed=false
	else
		if prelaunchpressed == false then
			-- only do this stuff once when prelaunch if first pressed
			prelaunchpressed = true
			if widget.sensor_altitude ~= nil then
				widget.sensor_altitude:reset()  -- reset the altitude height to zero to help compensate for altitude drift
			end
		end
		if lastTimeLanded == 0 then
			lastTimeLanded = os.clock()
		end
	end
	if (DebugLaunched) then print("FTRAIN: f3klaunched() ret=" .. tostring(ret) .. "PLpressed=" .. tostring(prelaunchpressed) .. " lastTimeLanded=" .. lastTimeLanded .. " time=" .. os.clock()) end
	return ret
end

function f3klanded(widget)
	local retVal = false
	local prelaunchpressed = widget.prelaunchswitch:state()
	if prelaunchpressed then
		lastTimeLanded = os.clock()
		retVal = true
	end
	if (DebugLanded) then print("FTRAIN: f3klanded() ret=" .. tostring(retVal) .. "PLpressed=" .. tostring(prelaunchpressed) .. " lastTimeLanded=" .. lastTimeLanded .. " time=" .. os.clock()) end
	return retVal
end

function f3kDrawTimer( x, y, value, flags )
	if value == nil then
		local text_w_timer, text_h_timer = lcd.getTextSize("00:00")
		lcd.drawText( x + text_w_timer/2, y, '--:--', CENTERED | flags )
	else
		local minutesText = math.floor(value / 60)
		local secondsText = value % 60
		lcd.drawText( x, y, string.format("%02d:%02d", minutesText, secondsText), flags)
	end
end

F3K_SCRIPT_PATH = "/SCRIPTS/F3K_TRAINING/"
SOUND_PATH = F3K_SCRIPT_PATH .. 'sounds/'

createTimer = dofile( F3K_SCRIPT_PATH .. 'timer.lua' )
createTimeKeeper = dofile( F3K_SCRIPT_PATH .. 'timekeeper.lua' )

local createMenu
local currentTask
	
local function drawEmptyTimer( x, y, flags )
	local text_w_timer, text_h_timer = lcd.getTextSize("00:00")
	lcd.drawText( x + text_w_timer/2, y, '--:--', CENTERED | flags )
end

local timersavailable = false
local function checkTimers( widget )
	if (DebugFunctionCalls) then print("FTRAIN: checkTimers()") end
	local available = 0
	local f3kzerofound = false
	local f3konefound = false
	for timerid=0,7 do
		local timer = model.getTimer(timerid)
		if timer == nil then
			available = available + 1
		elseif timer:name() == 'f3kOne' then
			f3konefound = true
		elseif timer:name() == 'f3kZero' then
			f3kzerofound = true
		end
		
		if (f3konefound and f3kzerofound) or (available >= 2) or (available == 1 and (f3kzerofound or f3konefound)) then
			timersavailable = true
		else
		end
	end
end

-- Switch position special characters... we can't use getSource("SA-") as the special characters seem to cause problems so we use member= instead
-- CATEGORY_SWITCH_POSITION members...
-- member[0]=SA┴  (UP)
-- member[1]=SA-  (MID)
-- member[2]=SA├  (DOWN)
-- member[3]=SB┴
-- member[4]=SB-
-- member[5]=SB├
-- member[6]=SC┴
-- member[7]=SC-
-- member[8]=SC├
-- member[9]=SD┴
-- member[10]=SD-
-- member[11]=SD├
-- member[12]=SE┴
-- member[13]=SE-
-- member[14]=SE├
-- member[15]=SF┴
-- member[16]=SF-
-- member[17]=SF├
-- member[18]=SG┴
-- member[19]=SG-
-- member[20]=SG├
-- member[21]=SH┴
-- member[22]=SH-
-- member[23]=SH├
-- member[24]=SI┴
-- member[25]=SI-
-- member[26]=SI├
-- member[27]=SJ┴
-- member[28]=SJ-
-- member[29]=SJ├

local function create()
	if (DebugFunctionCalls) then print("FTRAIN: create()") end
	currentTask = createMenu()
	checkTimers()
	--Default switche positions to menuswitch=SD- startswitch=SDdown prelaunchswitch=SIdown
	return {menuswitch=system.getSource({category=CATEGORY_SWITCH_POSITION, member=10}), startswitch=system.getSource({category=CATEGORY_SWITCH_POSITION, member=11}), prelaunchswitch=system.getSource({category=CATEGORY_SWITCH_POSITION, member=26}), menuscrollencoder=system.getSource("Throttle"), backgroundcolor=lcd.RGB(0,90,0), sensor_rssi=system.getSource("RSSI"), sensor_battery=system.getSource("RxBatt"), sensor_vspeed=system.getSource("VSpeed"), sensor_altitude=system.getSource("Altitude")}
end

--Read Configs from storage
local function read(widget)
	if (DebugFunctionCalls) then print("FTRAIN: read()") end
	if(not DebugConfig) then
		widget.menuswitch = storage.read("source")
		widget.startswitch = storage.read("source")
		widget.prelaunchswitch = storage.read("source")
		widget.menuscrollencoder = storage.read("source")
		widget.backgroundcolor = storage.read("color")
		widget.sensor_rssi = storage.read("source")
		widget.sensor_battery = storage.read("source")
		widget.sensor_vspeed = storage.read("source")
		widget.sensor_altitude = storage.read("source")
	end
end
--Write Configs on storage
local function write(widget)
	if (DebugFunctionCalls) then print("FTRAIN: write()") end
	if(not DebugConfig) then
		storage.write("source", widget.menuswitch)
		storage.write("source", widget.startswitch)
		storage.write("source", widget.prelaunchswitch)
		storage.write("source", widget.menuscrollencoder)
		storage.write("color", widget.backgroundcolor)
		storage.write("source", widget.sensor_rssi)
		storage.write("source", widget.sensor_battery)
		storage.write("source", widget.sensor_vspeed)
		storage.write("source", widget.sensor_altitude)
	end
end

local function inittask( win )
	currentTask.init( win )
end

local function background(widget)
	if (DebugFunctionCalls) then print("FTRAIN: background()") end
	if timersavailable == false then
		return
	elseif (widget.menuswitch == nil or widget.startswitch == nil or widget.prelaunchswitch == nil or widget.menuscrollencoder == nil) then
		return
	end
	
	if not currentTask.background(widget) then
		currentTask = createMenu()
	end
end

local function unsupportedDisplay( widget )
	lcd.font(FONT_S)
	local text_w, text_h = lcd.getTextSize("")
	 
	lcd.drawText( 0, 0, 'F3K Training' )
	lcd.drawText( 0, text_h, 'Unsupported widget size' )
	return true
end

local function noTimersAvailable( widget )
	lcd.font(FONT_S)
	local text_w, text_h = lcd.getTextSize("")
	 
	lcd.drawText( 0, 0, 'F3K Training' )
	lcd.drawText( 0, text_h, 'Not enough timers available.' )
	lcd.drawText( 0, text_h * 2, 'Need 2 available timers.' )
	return true
end

local function display( widget )
	--if (DebugFunctionCalls) then 
	if (DebugFunctionCalls) then print("FTRAIN: display() currentTask=" .. tostring(currentTask.name)) end
    local w, h = lcd.getWindowSize()
    local text_w, text_h = lcd.getTextSize("")

	local running	
	local widget_w, widget_h = lcd.getWindowSize()
	--print("widget_h", widget_w, widget_h)
	if timersavailable == false then
		running = noTimersAvailable( widget )
	elseif (widget.menuswitch == nil or widget.startswitch == nil or widget.prelaunchswitch == nil or widget.menuscrollencoder == nil) then
		lcd.color(BLACK)
		lcd.drawText(0, 0, "Configure widget needed" )
		return
	elseif widget_w  >= 784 and widget_h >= 294 then
		-- X20(s) Large Widget
		running = currentTask.display( widget )
	else
		running = unsupportedDisplay( widget )
	end

	if not running then
		currentTask = createMenu()
	end
end


local function configure(widget)
	if (DebugFunctionCalls) then print("FTRAIN: configure()") end
	-- source choices
	local line = form.addLine("Background Color")
	form.addColorField(line, nil, function() return widget.backgroundcolor end, function(value) widget.backgroundcolor = value end)
	line = form.addLine("Menu Select Switch Position")
	form.addSwitchField(line, nil, function() return widget.menuswitch end, function(value) widget.menuswitch = value end)
	line = form.addLine("Start Switch Position")
	form.addSwitchField(line, nil, function() return widget.startswitch end, function(value) widget.startswitch = value end)
	line = form.addLine("PreLaunch Switch Position")
	form.addSwitchField(line, nil, function() return widget.prelaunchswitch end, function(value) widget.prelaunchswitch = value end)
	line = form.addLine("Menu Scroll Analog")
	form.addSourceField(line, nil, function() return widget.menuscrollencoder end, function(value) widget.menuscrollencoder = value end)
	line = form.addLine("RSSI Telemetry sensor")
	form.addSourceField(line, nil, function() return widget.sensor_rssi end, function(value) widget.sensor_rssi = value end)
	line = form.addLine("Rx battery voltage sensor")
	form.addSourceField(line, nil, function() return widget.sensor_battery end, function(value) widget.sensor_battery = value end)
	line = form.addLine("Vario vertical speed sensor")
	form.addSourceField(line, nil, function() return widget.sensor_vspeed end, function(value) widget.sensor_vspeed = value end)
	line = form.addLine("Vario altitude sensor")
	form.addSourceField(line, nil, function() return widget.sensor_altitude end, function(value) widget.sensor_altitude = value end)

end


--[[
	UI to choose the task
--]]
createMenu = function()
	if (DebugFunctionCalls) then print("FTRAIN: createMenu()") end
	local TASKS = {
		{ id='A', desc='Last flight' },
		{ id='B', desc='Last two' },
		{ id='C', desc='AULD' },
		{ id='D', desc='Two Flights' },
		{ id='F', desc='3 out of 6' },
		{ id='G', desc='5x2' },
		{ id='H', desc='1234' },
		{ id='I', desc='Best three' },
		{ id='J', desc='Last three' },
		{ id='K', desc='Big Ladder' },
		{ id='L', desc='One flight' },
		{ id='M', desc='Huge Ladder' },
		{ id='A', desc='Last flight (7 min)', win=7 },
		{ id='B', desc='Last two (7 min)', win=7 },
		{ id='QT', desc='QT practice (15 x 40s)' },
		{ id='FF', desc='Free flight (simple timer)' }
	}

	local function dummy()
		return true
	end

	local selection=2
	local lastselection=nil
	
	local function display( widget )
		local forceRefresh = true
		if (DebugFunctionCalls) then print("FTRAIN: menu.display()") end

		local widget_w, widget_h = lcd.getWindowSize()
		if (DebugMenu) then print("widget_h=", widget_h, "widget_w=", widget_w) end

		lcd.font(FONT_XL)
		local text_w, text_h = lcd.getTextSize("A")
		if (DebugMenu) then print("text_w = ", text_w, "text_h = ", text_h) end

		local menuEntriesShown = math.floor( widget_h / text_h )
		if(DebugMenu) then print("F3KTRAIN: menu.display() menuEntriesShown = ", menuEntriesShown) end
		for i=0,menuEntriesShown - 1 do
			local halfMenuEntries = math.floor( menuEntriesShown / 2 )
			local ii = i + selection - halfMenuEntries + 1
			if ii >= 1 and ii <= #TASKS then
				if i == halfMenuEntries then
					lcd.color(widget.backgroundcolor)
					lcd.drawFilledRectangle( 0, 1 + text_h * i, widget_w - 130 - text_w - text_w, text_h )
					lcd.color(WHITE)
				else
					lcd.color(lcd.GREY(190))
				end
				lcd.drawText( text_w , 1 + text_h * i, TASKS[ ii ].id )
				if (DebugMenu) then print("FTRAIN: menu.display() LCDDraw", text_w, 1+ text_h * i, TASKS[ ii ].id ) end
				lcd.drawText( text_w * 4, 1 + text_h * i, TASKS[ ii ].desc )
			end
		end

		-- Draw the F3K Training name on right side of screen
		local menuF3kTextOffset = widget_w - 130
		lcd.color( widget.backgroundcolor )
		lcd.drawFilledRectangle( menuF3kTextOffset - 3, 8, 130, 80 )
		lcd.color( WHITE )
		lcd.drawText( menuF3kTextOffset, 8, 'F3K' )
		lcd.drawText( menuF3kTextOffset, 48, 'Training' )
		
		lcd.color( lcd.GREY(192) )  -- LIGHT_GREY
		lcd.drawText( widget_w - text_w * 4 - 2, widget_h - text_h, 'v' )
		lcd.drawText( widget_w - text_w * 3 - 2, widget_h - text_h, F3KVersion )
		lcd.color( BLACK )

		return true
	end
	
	local function background(widget)
		local div = 2048 / (#TASKS)  -- we want [0..n-1] steps
		if (DebugFunctionCalls) then print("FTRAIN: menu.background()") end
			
		selection = math.floor( (widget.menuscrollencoder:value() - 1024) / -div )
		if (selection ~= lastSelection) then
			if (DebugInvalidateWindow) then print("FTRAIN: menu.background() invalidate()") end
			lastSelection = selection
			lcd.invalidate()
		end

		if (DebugMenu) then print("FTRAIN: menu.display() widget.menuswitch:state() = ", widget.menuswitch:state() ) end
		if widget.menuswitch:state() then
			currentTask = dofile( F3K_SCRIPT_PATH .. 'WBig/view_' .. TASKS[ selection+1 ].id .. '.lua' )
			local win = TASKS[ selection+1 ].win or 10
			inittask( win * 60 )
		end
		
		-- Stop the timers (If they have been created) while in the menu
		local f3kZTimer = model.getTimer("f3kZero")
		local f3kOTimer = model.getTimer("f3kOne")
		if f3kZTimer ~= nil then
			local catNoneSource = system.getSource(nil)
			if f3kZTimer:activeCondition() ~= catNoneSource then
				f3kZTimer:activeCondition(catNoneSource)
			end
		end
		if f3kOTimer ~= nil then
			local catNoneSource = system.getSource(nil)
			if f3kZTimer:activeCondition() ~= catNoneSource then
				f3kZTimer:activeCondition(catNoneSource)
			end
		end
		
		return(true)
	end

	return { init=dummy, background=background, display=display }
end

currentTask = createMenu()

local function init()
	system.registerWidget({key="ftrain", name="F3K Training", options=options, create=create, wakeup=background, paint=display, configure=configure, read=read, write=write })
end

return {init=init}
