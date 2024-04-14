F3KVersion = '6.3.7'
--[[
	F3K Training - 	Mike, ON4MJ, 00steven
	 Ethos conversion by Adam Gibson (StatiC on RCGroups)

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
	4.1.3 Widget config to enable/disable announcing/displaying of launch height for FF task
	5.0.0 Initial release with support for X18, X18S, Twin X-Lite, and Twin X-Lite S support.
	      Initial support of X10 Express radio.  Probably still needs some display format tweaks.  Need feedback.
	      Fixed issue where using the switch to go back to the menu didn't take effect until you moved the stick
	      Disabled some left in debug print statements
	      Added new timekeeper.lua function setNextTime() to push times in next slot.  The 
	       other functions addTime() and pushTime() move the positions up as times are inserted into the time arrays
	      Redesigned view files so that they call functions in viewbase so that only viewbase needs to be different per
	       widget size.
	5.0.1 Consolidated quicktime task draw functionality into functions into viewbase
	      Added viewbase drawFlightCurrent() for functions to draw flight number and then current time
              Added viewbase drawDelta() for quicktime practice task
              More comments to viewbase lua file functions
	5.0.2 Added cycling the bottom right to cycle between launch height and max height for flight
              Fixed X10Express launch height dashboard displaying the height below the screen size
	5.0.3 Updated check for widget sizes to smaller sizes for screens with smaller LCD panels.  Ethos 1.4.14 made changes to avilable widget sizes (reduced)
    6.0.0 Updated for Ethos 1.5.0.  No longer compatible with 1.4.x Ethos.
          Fixed bug where timer:drawReverse was not drawing current flight time as up count.  It was showing the down count.
          Timer:activeCondition() is now timer:startCondition() so map the old to the new function if it doesn't exist on older firmware
          Added new 2024 task N (Best flight)
          Changes to deal with Timer:mode being removed in 1.5.0 firwmare and replaced with a new more customizable Timer:audioActions().
          f3kCreateTimer() now uses the new Ethos 1.5.0 audioTypes COUNTDOWN_BEEP and COUNTDOWN_VALUE instead of AUDIO_MODE defines from 1.4.x Ethos.
          Fixed bug where taskbase playTime() had a playsound for remaining prefix audio but that was mistakenly put in.  Prefix audio needs to be different in different sections of code like target and was already handled in the code before playTime().
    6.1.0 Fixed Done ! text not showing in the correct spot for Twin X-Lite S
          Made Done ! text location consistent between flight modes
          Changed task screen design to say Worktime/Preptime and Flight on Twin X-Lite S(472x191 viewbase.lua)
          Changed task screen design for X20S (784x294 viewbase.lua)
          Changed task screen design for X10EXPRESS (472x158 viewbase.lua)
          Removed F3K Training text on right hand side of flight screens so that space can be used for more useful stuff in the future
          Fixed Timer showing negative for FF task
          Changed H task to use down timer instead of up timer to match other F3K tasks
          Added getDirection() to timer as we need to know if it is an up or down timer for geting value of timer
          (-1 is down timer and 1 is up timer)
          Added missing prep/work time to task M screen
    6.1.1 Fixed display of Max alt. only working if DebugLaunchHeight debugging was enabled
          Fixed formating of right side display on all models.  Smallest display couldn't show launch height and some were cut off.
    6.2.0 Detect radio model and set menu and start switches as well as pre-launch to a usable default
          Assign RSSI source to first detected "RSSI", "RSSI 2.4G", "RSSI 900M", in that order to set to a sane default
    6.2.1 Bump version because of bad commit
    6.2.2 Fixed QT task not showing work/prep time
    6.3.0 Moved the 7 min a and b tasks near the top so they are listed with the other a and b tasks.
          Added separator for non-FAI tasks like QT and Free Flight
          Added widget option to select when to play task introduction. When selecting the task, The start of the task, or disable it.
          Task introduction audio play time is added to prep time to make sure it doesn't conflict with prep time count down.  In other words, If task introduction is set to 'start of task' then prep time starts when task intruduction is done.
          Added widget option to set custom prep time.
          Added widget option to start worktime on launch.  This disables prep time of course.
          Changed it so that Done ! is shown where Worktime text is on the screen when task completes fixing where it was displayed in the wrong spot before.  Moved that code to viewbase also to simplify view_X.lua files.
          The last Flight time is left on the screen when the task is Done.  I kind of like being able to see that last time in bigger text.  I can likely be persuaded to change it back though and remove the Flight time on the left when task is done.
          Removed redundant code for task completion 'Done !' text in drawImproveMargin function.
    6.3.1 Bugfix.  FF task not shown.
    6.3.2 Bugfix...Change new option to start worktime on launch to false to stay with old behavior by default
    6.3.3 Bugfix Task C and F didn't start flight time when 'start worktime on launch' widget option was set
    6.3.4 Bugfix Last fix for Task C and F referenced the wrong function names
    6.3.5 Bugfix Task C Didn't show worktime
    6.3.6 Bugfix Task B didn't start.  Left an errant end statem in view_b.lua when moving the printing of the Done text.
    6.3.7 Bugfix Task C fixed again
          Added more time between task announcement and start of count down so that announcements don't conflict with start of prep count down
--]]

-- 1.5.0 firmware changed Timer.activeCondition to Timer.startCondition so make older firmware
-- map the old function also to the new name.  There are other things different that aren't
-- accounted for with older 1.4.x Ethos so this is really useless since 1.4.x doesn't work anymore
-- with this code... leaving it in to remind myself how to do it :)
if (_G['Timer']['startCondition'] == nil) then
    Timer.startCondition = Timer.activeCondition
end

local FTRAINDebug=0

DebugFunctionCalls=false
DebugInvalidateWindow=false
DebugConfig=false
DebugMenu=false
DebugLaunched=false
DebugLanded=false
DebugTimes=false
DebugTimers=false
DebugLaunchHeight=false  -- only implemented on x20(s) 784x294 screeen and shows max vspeed attained

-- Global used to know what directory to use for widget display lua code files
FTRAINwidgetresolution = ""

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

FTRAIN_INTRO_MODE_DISABLED = 0
FTRAIN_INTRO_MODE_START = 1
FTRAIN_INTRO_MODE_SELECT = 2
FTRAIN_INTRO_MODE_DEFAULT = FTRAIN_INTRO_MODE_START

-- can be adjusted in widget config
FTRAIN_PREP_TIME_DEFAULT = 15
FTRAIN_PREP_TIME_MIN = 0
FTRAIN_PREP_TIME_MAX = 60

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
	local menuswitch
	local startswitch
	local board=system.getVersion().board
	print ( "FTRAIN: board=" .. board )
	if ( board == "TWXLITES" or board == "TWXLITE" ) then
		menusw=4
		startsw=5
		prelsw=14
	elseif ( board == "X10EXPRESS" or board == "X10SEXPRESS" or board == "X12S" ) then
		menusw=10
		startsw=11
		prelsw=17
	else  --( board == "X20S" or board == "X20" or board == "X18" or board == "X18S" ) then
		menusw=10
		startsw=11
		prelsw=26
	end
	local rssisrc
	rssisrc = system.getSource("RSSI")
	if rssisrc == nil then
		rssisrc = system.getSource("RSSI 2.4G")
        if rssisrc == nil then
            rssisrc = system.getSource("RSSI 900M")
        end
    end
	--Default switche positions to menuswitch=SD- startswitch=SDdown prelaunchswitch=SIdown
	return {menuswitch=system.getSource({category=CATEGORY_SWITCH_POSITION, member=menusw}), startswitch=system.getSource({category=CATEGORY_SWITCH_POSITION, member=startsw}), prelaunchswitch=system.getSource({category=CATEGORY_SWITCH_POSITION, member=prelsw}), menuscrollencoder=system.getSource("Throttle"), backgroundcolor=lcd.RGB(0,90,0), sensor_rssi=rssisrc, sensor_battery=system.getSource("RxBatt"), sensor_vspeed=system.getSource("VSpeed"), sensor_altitude=system.getSource("Altitude"), launch_height_enabled=true,task_intro_mode=FTRAIN_INTRO_MODE_DEFAULT, prep_time=FTRAIN_PREP_TIME_DEFAULT, start_worktime_on_launch=false}
end

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
		widget.launch_height_enabled = storage.read("bool")
		widget.task_intro_mode = storage.read("number")
		if widget.task_intro_mode == nil or widget.task_intro_mode < 0 or widget.task_intro_mode > 2 then
			widget.task_intro_mode = FTRAIN_INTRO_MODE_DEFAULT
		end
		widget.prep_time = storage.read("number")
		if widget.prep_time == nil or widget.prep_time < FTRAIN_PREP_TIME_MIN or widget.prep_time > FTRAIN_PREP_TIME_MAX then
			widget.prep_time = FTRAIN_PREP_TIME_DEFAULT
		end
		widget.start_worktime_on_launch = storage.read("bool")
		if widget.start_worktime_on_launch == nil then
			widget.start_worktime_on_launch = false
		end
	end
end

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
		storage.write("bool", widget.launch_height_enabled)
		storage.write("number", widget.task_intro_mode)
		storage.write("number", widget.prep_time)
		storage.write("bool", widget.start_worktime_on_launch)
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
    local lwidget_w, lwidget_h = lcd.getWindowSize()
    local screenrestext = string.format("%d x %d", lwidget_w, lwidget_h )
    lcd.drawText( 0, text_h * 2, screenrestext )
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
	elseif (widget_w >= 472 and widget_h >= 155) then
		FTRAINwidgetresolution = "472x158"  -- it is actually 158 now in Ethos 1.4.14 but leave as 155 so older versions of Ethos are supported
		if (widget_w >= 472 and widget_h >= 191) then
			FTRAINwidgetresolution = "472x191"
			if (widget_w  >= 784 and widget_h >= 294) then
				FTRAINwidgetresolution = "784x294"
			end
		end
        running = currentTask.display( widget )
	else
		running = unsupportedDisplay( widget )
	end

	if not running then
		currentTask = createMenu()
	end
end


local function configure(widget)
	local introModes = { {"Start of task", FTRAIN_INTRO_MODE_START}, {"Select task", FTRAIN_INTRO_MODE_SELECT} , {"Disable", FTRAIN_INTRO_MODE_DISABLED} }
	if (DebugFunctionCalls) then print("FTRAIN: configure()") end
	-- source choices
	local line = form.addLine("FF Launch height enabled")
	form.addBooleanField(line, nil, function() return widget.launch_height_enabled end, function(value) widget.launch_height_enabled = value end)
	line = form.addLine("Start worktime on launch")
	form.addBooleanField(line, nil, function() return widget.start_worktime_on_launch end, function(value) widget.start_worktime_on_launch = value end)
	line = form.addLine("Prep time")
	form.addNumberField(line, nil, FTRAIN_PREP_TIME_MIN, FTRAIN_PREP_TIME_MAX, function() return widget.prep_time end, function(value) widget.prep_time = value end)
	line = form.addLine("Play task introduction")
	form.addChoiceField(line, nil, introModes, function() return widget.task_intro_mode end, function(value) widget.task_intro_mode = value end)
	line = form.addLine("Background Color")
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
		{ id='A', desc='Last flight (10m)' },
		{ id='A', desc='Last flight (7m)', win=7 },
		{ id='B', desc='Last two (10m)' },
		{ id='B', desc='Last two (7m)', win=7 },
		{ id='C', desc='AULD' },
		{ id='D', desc='Two flights' },
		{ id='F', desc='3 out of 6' },
		{ id='G', desc='5x2' },
		{ id='H', desc='1234' },
		{ id='I', desc='Best three' },
		{ id='J', desc='Last three' },
		{ id='K', desc='Big ladder' },
		{ id='L', desc='One flight' },
		{ id='M', desc='Huge ladder' },
		{ id='N', desc='Best flight' },
		{ id='--', desc='[ Non-FAI tasks ]' },
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

		lcd.font(XL)

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
	
	local function bool_to_number(value)
		return value and 1 or 0
	end
	
	local LastMenuSwitchStates = 0
	
	local function background(widget)
		local div = 2048 / (#TASKS)  -- we want [0..n-1] steps
		
		-- Make sure when the menuswitch or startswitch state changes, invalidate the lcd window to force a redraw
		local menuswitchesstates = bool_to_number(widget.menuswitch:state()) + bool_to_number(widget.startswitch:state())
		if (LastMenuSwitchStates ~= menuswitchstates) then
			lcd.invalidate()
			LastMenuSwitchStates = menuswitchesstates
		end
		if (DebugFunctionCalls) then print("FTRAIN: menu.background()") end
			
		selection = math.floor( (widget.menuscrollencoder:value() - 1024) / -div )
		if (selection ~= lastSelection) then
			if (DebugInvalidateWindow) then print("FTRAIN: menu.background() invalidate()") end
			lastSelection = selection
			lcd.invalidate()
		end

		if (DebugMenu) then print("FTRAIN: menu.display() widget.menuswitch:state() = ", widget.menuswitch:state() ) end
		if widget.menuswitch:state() and TASKS[ selection+1 ].id ~= '--' then
			currentTask = dofile( F3K_SCRIPT_PATH .. 'view_' .. TASKS[ selection+1 ].id .. '.lua' )
			local win = TASKS[ selection+1 ].win or 10
			inittask( win * 60 )
		end
		
		-- Stop the timers (If they have been created) while in the menu
		local f3kZTimer = model.getTimer("f3kZero")
		local f3kOTimer = model.getTimer("f3kOne")
		if f3kZTimer ~= nil then
			local catNoneSource = system.getSource(nil)
			if f3kZTimer:startCondition() ~= catNoneSource then
				f3kZTimer:startCondition(catNoneSource)
			end
		end
		if f3kOTimer ~= nil then
			local catNoneSource = system.getSource(nil)
			if f3kZTimer:startCondition() ~= catNoneSource then
				f3kZTimer:startCondition(catNoneSource)
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
