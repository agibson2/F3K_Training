F3KVersion = '3.02'
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
--]]

F3K_SCRIPT_PATH = "/WIDGETS/F3K_TRAINING/"

F3KConfig = dofile( F3K_SCRIPT_PATH .. 'custom.lua')

OpenTX = dofile( F3K_SCRIPT_PATH .. 'opentx_srv.lua' )

createTimer = dofile( F3K_SCRIPT_PATH .. 'timer.lua' )
createTimeKeeper = dofile( F3K_SCRIPT_PATH .. 'timekeeper.lua' )

local createMenu
local currentTask


-- This only gets called by OpenTX 2.2 when run as a Widget (As of 2017-03-17 only available on Horus)
local function create( zone, options )
	local context = { zone=zone, options=options }
	Options = options
	currentTask = createMenu()
	return context
end


local function init( win )
	currentTask.init( win )
end


local function background()
	if not currentTask.background() then
		currentTask = createMenu()
	end
end


local function unsupportedDisplay( context )
	OpenTX.lcd.drawText( 2, 0, 'F3K Training', INVERS )
	OpenTX.lcd.drawText( 8, 20, 'Unsupported widget size', SMLSIZE )
	return true
end


local function display( context )
	local running

	OpenTX.lcd.updateContext( context )

	if context.zone.w  > 380 and context.zone.h > 165 then
		-- Horus Large Widget
		running = currentTask.display( context )
	else
		running = unsupportedDisplay( context )
	end

	if not running then
		currentTask = createMenu()
	end
end


local function update( context, options )
	Options = options
end


--[[
	UI to choose the task
--]]
createMenu = function()
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


	local function display( context )
		local FONT_HEIGHT = 20
		local FONT_WIDTH = 12
		
		local div = 2048 / (#TASKS)  -- we want [0..n-1] steps
		local selection = math.floor( (getValue( Options.MenuScrollEncoder ) - 1024) / -div )

		local menuEntriesShown = math.floor( context.zone.h / FONT_HEIGHT )
		
		for i=0,menuEntriesShown - 1 do
			local att = 0
			local halfMenuEntries = math.floor( menuEntriesShown / 2 )
			if i == halfMenuEntries then
				att = INVERS
			end
			local ii = i + selection - halfMenuEntries + 1
			if ii >= 1 and ii <= #TASKS then
				OpenTX.lcd.drawText( FONT_WIDTH , 1 + FONT_HEIGHT * i, TASKS[ ii ].id, att )
				OpenTX.lcd.drawText( FONT_WIDTH * 4, 1 + FONT_HEIGHT * i, TASKS[ ii ].desc, att )
			end
		end

		local menuF3kTextOffset = context.zone.w - 78

		if menuF3kTextOffset > 22 * FONT_WIDTH then
			OpenTX.lcd.setColor( TEXT_COLOR, LIGHTGREY )
			OpenTX.lcd.drawFilledRectangle( menuF3kTextOffset - 3, 8, 72, 61 )
			OpenTX.lcd.setColor( TEXT_COLOR, DARKGREY )
			OpenTX.lcd.drawText( menuF3kTextOffset, 8, 'F3K', DBLSIZE )
			OpenTX.lcd.drawText( menuF3kTextOffset, 48, 'Training', 0 )
		end
		
		OpenTX.lcd.setColor( TEXT_COLOR, LIGHTGREY )
		OpenTX.lcd.drawFilledRectangle( context.zone.w - FONT_WIDTH * 4 - 2, context.zone.h - FONT_HEIGHT, FONT_WIDTH * 4, FONT_HEIGHT - 1, GREY_DEFAULT )
		OpenTX.lcd.setColor( TEXT_COLOR, DARKGREY )
		OpenTX.lcd.drawText( context.zone.w - FONT_WIDTH * 4 - 2, context.zone.h - FONT_HEIGHT, 'v', 0 )
		OpenTX.lcd.drawText( context.zone.w - FONT_WIDTH * 3 - 2, context.zone.h - FONT_HEIGHT, F3KVersion, 0 )
		OpenTX.lcd.setColor( TEXT_COLOR, BLACK )

		if getValue( Options.MenuSwitch ) >= 0 then
			currentTask = dofile( F3K_SCRIPT_PATH .. 'WBig/view_' .. TASKS[ selection+1 ].id .. '.lua' )
			local win = TASKS[ selection+1 ].win or 10
			init( win * 60 )
		end

		return true
	end

	return { init=dummy, background=dummy, display=display }
end

currentTask = createMenu()


local options = {
	{ 'MenuSwitch', SOURCE, F3KConfig.MENU_SWITCH },
	{ 'PrelaunchSwitch', SOURCE, F3KConfig.PRELAUNCH_SWITCH },
	{ 'MenuScrollEncoder', SOURCE, F3KConfig.MENU_SCROLL_ENCODER },
	{ 'BackgroundColor', COLOR, WHITE }
}


return { name="F3KTrain", options=options, create=create, update=update, background=background, refresh=display }
