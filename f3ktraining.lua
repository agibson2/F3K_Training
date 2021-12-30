F3KVersion = '4.00'
--[[
	F3K Training - 	Mike, ON4MJ

	telemN.lua
	Main script (provides the UI and loads the relevant task script)

	This is a telemetry script
	REQUIRES OpenTX 2.0.13+

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
	2.06    xStatiCa (Adam) - Imlemented Horus compatibility for large Widget size.  Other widget sizes will not display properly.
			Allow persistent storage of options if run as a Widget (options storage is a feature of Widgets).

	3.00	Refactoring again : separated the views from the domain.  
		The goal was to go multi-platform : Q7 and Horus (large for now) Widgets support
		Added 2.2 compatibility for the Taranis
	3.01	Horus widget fix : browsing through widgets to install a new one in another zone broke an already installed Training widget.
	3.02	Added AULD
		Fixed a regression introduced in 3.00 where a false launch could be detected when running the same task more than once
	4.00    xStatiCa (Adam) - Major Ethos changes which removes OpenTX compatibility
--]]

local FTRAINDebug=0

local DebugFunctionCalls=false
local DebugInvalidateWindow=false
local DebugConfig=false
local DebugMenu=false
local DebugLaunched=false

if(FTRAINDebug >= 1) then
	DebugInvalidateWindow=true
	--DebugConfig=true
end
if(FTRAINDebug >= 2) then
	DebugFunctionCalls=true
	DebugLaunched=true
end
if(FTRAINDebug >= 3) then
	--DebugMenu=true
end


local lastTimeLanded = 0	-- 0=must pull first ; other=time of the last pull

local function resetLaunchDetection()
	lastTimeLanded = 0
end

function getTime()
	return os.clock()*1000 -- 1/100th
end

-- >>> Launch / Land detection <<< ---
function f3klaunched(widget)
	local ret = false
	local prelaunchpressed=false
	if not widget.prelaunchswitch:state() then
		-- if the tmp switch is held for more than 0.6s, it's a launch ;
		-- otherwise it was just a trigger pull to indicate that the plane has landed
		if lastTimeLanded > 0 then
			if (getTime() - lastTimeLanded) > 6000 then   -- 60 milliseconds FIXME this needs to be 6000 for X20S and 600 for simulator
				ret = true
			end
			lastTimeLanded = 0
		end
	else
		prelaunchpressed=true
		if lastTimeLanded == 0 then
			lastTimeLanded = getTime()
		end
	end
	if (DebugLaunched) then print("FTRAIN: f3klaunched() ret=" .. tostring(ret) .. "PLpressed=" .. tostring(prelaunchpressed) .. " lastTimeLanded=" .. lastTimeLanded .. " time=" .. getTime()) end
	return ret
end

function f3klanded(widget)
	if widget.prelaunchswitch:state() then
		lastTimeLanded = getTime()
		return true
	end
	return false
end

function f3kDrawTimer( x, y, value, flags )
	if value == nil then
		lcd.drawText( x, y, '--:--', flags )
	else
		local minutesText = math.floor(value / 60)
		local secondsText = value % 60
		lcd.drawText( x, y, string.format("%02d:%02d", minutesText, secondsText), flags)
	end
end

F3K_SCRIPT_PATH = "/SCRIPTS/F3K_TRAINING/"
SOUND_PATH = F3K_SCRIPT_PATH .. 'sounds/'

--OpenTX = dofile( F3K_SCRIPT_PATH .. 'opentx_srv.lua' )

createTimer = dofile( F3K_SCRIPT_PATH .. 'timer.lua' )
createTimeKeeper = dofile( F3K_SCRIPT_PATH .. 'timekeeper.lua' )

local createMenu
local currentTask
	
local function drawEmptyTimer( x, y, flags )
	lcd.drawText( x, y, '--:--', flags )
end

local timersavailable = false
local function checkTimers( widget )
	if (DebugFunctionCalls) then print("FTRAIN: checkTimers()") end
	local available = 0
	for timerid=0,7 do
		local timer = model.getTimer(timerid)
		local f3kzerofound = false
		local f3konefound = false
		if timer == nil then
			available = available + 1
		elseif timer:name() == 'f3kOne' then
			f3konefound = true
		elseif timer:name() == 'f3kZero' then
			f3kzerofound = true
		end
		
		if (f3konefound and f3kzerofound) or (available >= 2) or (available == 1 and (f3kzerofound or f3konefound)) then
			timersavailable = true
		end
	end
end

local function create()
	if (DebugFunctionCalls) then print("FTRAIN: create()") end
	currentTask = createMenu()
	checkTimers()
	if(DebugConfig) then
		local tmpms=system.getSource("SC")
		local tmpps=system.getSource("SA")
		local tmpme=system.getSource("THROTTLE")
		print ("FTRAIN: create() returnvals = ", tmpms, tmpps, tmpme)
		return {menuswitch=tmpms, prelaunchswitch=tmpps, menuscrollencoder=tmpme}
	else
		return {menuswitch=nil, prelaunchswitch=nil, menuscrollencoder=nil}
	end
end

local function read(widget)
	if (DebugFunctionCalls) then print("FTRAIN: read()") end
	if(not DebugConfig) then
		widget.menuswitch = storage.read("source")
		widget.prelaunchswitch = storage.read("source")
		widget.menuscrollencoder = storage.read("source")
	end
end

local function write(widget)
	if (DebugFunctionCalls) then print("FTRAIN: write()") end
	if(not DebugConfig) then
		storage.write("source", widget.menuswitch)
		storage.write("source", widget.prelaunchswitch)
		storage.write("source", widget.menuscrollencoder)
	end
end

local function inittask( win )
	currentTask.init( win )
end

local function background(widget)
	if (DebugFunctionCalls) then print("FTRAIN: background()") end
	if timersavailable == false then
		return
	end
	
	if not currentTask.background(widget) then
		currentTask = createMenu()
	end
end

local function unsupportedDisplay( widget )
	lcd.font(S)
	local text_w, text_h = lcd.getTextSize("")
	 
	lcd.drawText( 0, 0, 'F3K Training', BOLD )
	lcd.drawText( 0, text_h, 'Unsupported widget size', 0 )
	return true
end

local function noTimersAvailable( widget )
	lcd.font(S)
	local text_w, text_h = lcd.getTextSize("")
	 
	lcd.drawText( 0, 0, 'F3K Training', BOLD )
	lcd.drawText( 0, text_h, 'Not enough timers available.', 0 )
	lcd.drawText( 0, text_h * 2, 'Need 2 available timers.', 0 )
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
	elseif (widget.menuswitch == nil) then
		lcd.color(BLACK)
		lcd.drawText(0, 0, "Configure widget needed", 0)
		return
	elseif widget_w  >= 784 and widget_h >= 294 then
		-- X20(s) Large Widget
		running = currentTask.display( widget )
	else
		running = unsupportedDisplay( widget )
	end

   -- if widget.menuswitch ~= nil then
    --    lcd.font(XL)
	--	--lcd.drawText(w/2, ((h - text_h)/2) - text_h, "widget.menuswitch:raw() = "..widget.menuswitch:raw(), CENTERED)
    --    lcd.drawText(w/2, (h - text_h)/2, "widget.menuswitch:value() = "..widget.menuswitch:value(), CENTERED)
	--	--lcd.drawText(w/2, ((h - text_h)/2) + text_h, "widget.menuswitch:unit() = "..widget.menuswitch:unit(), CENTERED)
	--	--lcd.drawText(w/2, ((h - text_h)/2) + (text_h * 2), "widget.menuswitch:stringUnit() = "..widget.menuswitch:unit(), CENTERED)
	--	lcd.drawText(w/2, ((h - text_h)/2) + (text_h * 3), "widget.menuswitch:stringValue() = "..widget.menuswitch:stringValue(), CENTERED)
    --end

	if not running then
		currentTask = createMenu()
	end
end


local function configure(widget)
	if (DebugFunctionCalls) then print("FTRAIN: configure()") end
	-- source choices
	line = form.addLine("MenuSwitch")
	form.addSwitchField(line, form.getFieldSlots(line)[0], function() return widget.menuswitch end, function(value) widget.menuswitch = value end)
	line = form.addLine("PreLaunchSwitch")
	form.addSwitchField(line, form.getFieldSlots(line)[0], function() return widget.prelaunchswitch end, function(value) widget.prelaunchswitch = value end)
	line = form.addLine("MenuScrollEncoder")
	form.addSourceField(line, form.getFieldSlots(line)[0], function() return widget.menuscrollencoder end, function(value) widget.menuscrollencoder = value end)
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
		{ id='L', desc='One flight' },
		{ id='M', desc='Big Ladder' },
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

-- Define positions
		if widget_h < 50 then
			lcd.font(XS)
		elseif widget_h < 80 then
			lcd.font(S)
		elseif widget_h > 170 then
			lcd.font(XL)
		else
			lcd.font(STD)
		end

		local text_w, text_h = lcd.getTextSize("A")
		if (DebugMenu) then print("text_w = ", text_w, "text_h = ", text_h) end

		local menuEntriesShown = math.floor( widget_h / text_h )
		if(DebugMenu) then print("F3KTRAIN: menu.display() menuEntriesShown = ", menuEntriesShown) end
		for i=0,menuEntriesShown - 1 do
			local att = STD
			local halfMenuEntries = math.floor( menuEntriesShown / 2 )
			if i == halfMenuEntries then
				lcd.color(GREEN)
				lcd.drawFilledRectangle( 0, 1 + text_h * i, widget_w - 130 - text_w - text_w, text_h )
				--att = BOLD
			end
			local ii = i + selection - halfMenuEntries + 1
			if ii >= 1 and ii <= #TASKS then
				if i == halfMenuEntries then
					lcd.color(BLACK)
				else
					lcd.color(WHITE)
				end
				lcd.drawText( text_w , 1 + text_h * i, TASKS[ ii ].id, att )
				if (DebugMenu) then print("FTRAIN: menu.display() LCDDraw", text_w, 1+ text_h * i, TASKS[ ii ].id, att ) end
				lcd.drawText( text_w * 4, 1 + text_h * i, TASKS[ ii ].desc, att )
			end
		end

		local menuF3kTextOffset = widget_w - 130

		if menuF3kTextOffset > 22 * text_w then
			--lcd.color( 192, 192, 192 )  -- LIGHT_GREY = Silver
			lcd.color( WHITE )  -- DARKGREY = Gray
			lcd.drawFilledRectangle( menuF3kTextOffset - 3, 8, 130, 80 )
			--lcd.color( 128, 128, 128 )  -- DARKGREY = Gray
			lcd.color( GREEN )  -- DARKGREY = White
			lcd.drawText( menuF3kTextOffset, 8, 'F3K', DBLSIZE )
			lcd.color( GREEN )  -- Ethos Green
			lcd.drawText( menuF3kTextOffset, 48, 'Training', 0 )
		end
		
		lcd.color( BROWN )  -- LIGHT_GREY = Gray
		lcd.drawFilledRectangle( widget_h - text_w * 4 - 2, widget_h - text_h, text_w * 4, text_h - 1, GREY_DEFAULT )
		lcd.color( BROWN ) -- DARKGREY = Gray
		lcd.drawText( widget_w - text_w * 4 - 2, widget_h - text_h, 'v', 0 )
		lcd.drawText( widget_w - text_w * 3 - 2, widget_h - text_h, F3KVersion, 0 )
		lcd.color( BLACK ) -- BLACK = Black

		--paintRanOnce=true
		--needToDisplayNewStuff=false
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
		
		return(true)
	end

	return { init=dummy, background=background, display=display }
end

currentTask = createMenu()

local function init()
	system.registerWidget({key="ftrain", name="F3K Training", options=options, create=create, wakeup=background, paint=display, configure=configure, read=read, write=write })
end

return {init=init}
