--[[
	F3K Training - 	Mike, ON4MJ
	                Adam, StatiC

	WBig/viewbase.lua
	Big widget views common stuff
--]]

local vbase = {}

-- 
--  |-----------------------|
--  |       |           | E |
--  |   A   |____B______|---|
--  |-------|           |   |
--  |   C   |    D      | F |
--  |       |           |   |
--  |-----------------------|
--
--  General layout above
--  A is usually the session timer
--  B is usually the flight timer list
--  C is usually the current flight timer
--  D is usually the accumalated valid flight time
--  E is F3K title   (generated by drawDashboard)
--  F is for sensor monitoring  (generated by drawDashboard

-- These are customized for each Widget size
vbase.horizontaldividery = 180 -- 110 --115 -- 76
vbase.verticaldividerx = 303 -- 185 --280
vbase.f3kDashboardOffset = 156 -- 96 --143

function vbase.drawDashboard( widget, task )
	local widget_w, widget_h = lcd.getWindowSize()
	lcd.font(FONT_L)
	local text_w, text_h = lcd.getTextSize("0")
	local f3kTextOffset = widget_w - vbase.f3kDashboardOffset
	
	lcd.color(WHITE)
	if widget.sensor_battery ~= nil then
		lcd.drawText( f3kTextOffset + 4, text_h*3 +3, "Rx Battery" )
		lcd.drawNumber( f3kTextOffset + 4 + text_w*6 -3, text_h*4 +4, widget.sensor_battery:value(), UNIT_VOLT, 2, RIGHT)
	end
	if widget.sensor_rssi ~= nil then
		lcd.drawText( f3kTextOffset + 4, text_h*5 +5, "Rx RSSI" )
		lcd.drawNumber( f3kTextOffset + 4 + text_w*6, text_h*6 +6, widget.sensor_rssi:value(), UNIT_DB, 0, RIGHT )
	end
	
	-- launch height for Free Flight task
	if task ~= nil and task.name == "Free Flight" and widget.launch_height_enabled then
		if widget.sensor_vspeed == nil or widget.sensor_altitude == nil or task.launchheight == nil then
			lcd.drawText( f3kTextOffset + 4, text_h*7 +7, "Launch" )
			lcd.drawText( f3kTextOffset + 4 + text_w*1, text_h*8 +8, "disabled" ) 
		else
			local altitudeval
			local heightlabel = ""
			-- Flip back and forth every 4 seconds between height after vspeed slows down and maximum height seen during flight
			if os.clock() % 8 < 4 then
				heightlabel = "Launch"
				altitudeval = task.launchheight
			else
				heightlabel = "Max alt."
				altitudeval = task.maxaltitude
			end
			
			lcd.drawText( f3kTextOffset + 4, text_h*7 +7, heightlabel )
			lcd.drawNumber( f3kTextOffset + 4 + text_w*6, text_h*8 +8, altitudeval, widget.sensor_altitude:unit(), 0, RIGHT )
		end

		if (DebugLaunchHeight) then
			lcd.drawNumber( text_w*8, widget_h - (text_h * 2), widget.sensor_vspeed:value(), widget.sensor_vspeed:unit(), 1, RIGHT ) --DEBUG
			lcd.drawNumber( text_w*16, widget_h - (text_h * 2), task.maxvspeed, widget.sensor_vspeed:unit(), 1, RIGHT ) --DEBUG
		end
	end
end

function vbase.drawPrepWorkTime( widget, task )
	lcd.font(FONT_XL)
	local text_w, text_h = lcd.getTextSize("0")
	local prefixString
	if not widget.start_worktime_on_launch and (task.state == 1 or task.state == 2) then
		prefixString = "Preptime"
	else
		if task.state == 5 then
			prefixString = "DONE !"
		else
			prefixString = "Worktime"
		end
	end
	lcd.drawText( text_w * 1, text_h, prefixString, 0 )
	lcd.font(FONT_XXL)
	task.timer1.draw( text_w * 3, text_h * 2, 0 )
end

-- Draw common stuff for every task
function vbase.drawCommon( widget, task )
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset

	lcd.color( widget.backgroundcolor )
	-- background rect right side
	lcd.drawFilledRectangle( vbase.verticaldividerx, 0, widget_w - vbase.verticaldividerx, widget_h - 1, 0 )
	-- outline left side
	lcd.color(BLACK)
	lcd.drawLine( 0, vbase.horizontaldividery, 0, widget_h, SOLID, 2 )
	-- outline at top of right box
	lcd.drawLine( vbase.verticaldividerx, 0, widget_w, 0, SOLID, 2 )
	-- outline at right side
	lcd.drawLine( widget_w, 0, widget_w, widget_h, SOLID, 2 )
	-- outline at bottom
	lcd.drawLine( 0, widget_h, widget_w, widget_h, SOLID, 2 )

	lcd.color(WHITE)
	lcd.font(FONT_L)
	local text_w, text_h = lcd.getTextSize("0")
	lcd.drawText( text_w, 0, task.name )
	lcd.color(BLACK)
	lcd.drawLine( vbase.verticaldividerx, 0, vbase.verticaldividerx, widget_h - 1, SOLID, 2 )
	
	vbase.drawDashboard( widget )
end

-- Draw current time on bottom left side area C
function vbase.drawCurrent( widget, task )
	lcd.font(FONT_XL)
	lcd.color(WHITE)
	local text_w, text_h = lcd.getTextSize("0")
	lcd.drawText( text_w * 1, text_h * 4, 'Flight' )
	lcd.font(FONT_XXL)
	if task.timer2.getDirection() == -1 then
		task.timer2.drawReverse( text_w * 3, text_h * 5, 0 )
	else
		-- ff and qt tasks have up timers
		task.timer2.draw( text_w * 3, text_h * 5, 0 )
	end
end

-- Draw target time and current time on bottom left side area C
function vbase.drawTargetCurrent( widget, task )
	lcd.font(FONT_XL)
	lcd.color(WHITE)
	local prefixText = task.MAX_FLIGHT_TIME .. 's: '
	local text_w, text_h = lcd.getTextSize("0")
    lcd.drawText( text_w * 1, text_h * 4, 'Target ' .. prefixText )
	lcd.font(FONT_XXL)
	task.timer2.drawReverse( text_w * 3, text_h * 5, 0 )
end

-- Draw flight count and current time on bottom left side area C
function vbase.drawFlightCurrent( widget, task )
	lcd.font(FONT_XL)
	lcd.color(WHITE)
	local text_w, text_h = lcd.getTextSize("0")
	lcd.drawText( text_w * 1, text_h * 4,'Flight ' .. math.max( 1, task.flightCount ) )
	lcd.font(FONT_XL)
	task.timer2.drawReverse( text_w * 3, text_h * 5, 0 )
end

-- Draw delta on top right side area B
function vbase.drawDelta( widget, task )
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset  -- exclude right side for dashboard

	lcd.font(FONT_L)
	local text_w, text_h = lcd.getTextSize("0")
	lcd.drawText( vbase.verticaldividerx + 8 + text_w * 3, 8, 'Delta' )
	lcd.drawText( vbase.verticaldividerx + 8 + text_w * 1, 8 + text_h, 'min' )
	lcd.drawText( vbase.verticaldividerx + 8 + text_w * 7, 8 + text_h, 'max' )
	lcd.color(BLACK)
	lcd.drawLine( vbase.verticaldividerx, 8 + text_h * 2, widget_w, 8 + text_h * 2 ) -- line below min max
	lcd.drawLine( vbase.verticaldividerx, 8 + text_h * 3, widget_w, 8 + text_h *3 ) --separator for min max values

	local xmiddleline = vbase.verticaldividerx + 8 + 70
	lcd.drawLine( xmiddleline, 8 + text_h * 2, xmiddleline, 8 + text_h * 3, SOLID, 2 ) -- line below min max values

	lcd.color(WHITE)
	lcd.drawNumber( vbase.verticaldividerx + 8 + text_w * 5, 8 + text_h * 2, task.deltas.min, UNIT_SECOND, 0, RIGHT )
	lcd.drawNumber( vbase.verticaldividerx + 8 + text_w * 11, 8 + text_h * 2, task.deltas.max, UNIT_SECOND, 0, RIGHT )

	lcd.drawText( vbase.verticaldividerx + 8, 8 + text_h * 3, 'average' )
	lcd.drawNumber( vbase.verticaldividerx + 8 + text_w * 11, 8 + text_h * 3, task.deltas.avg, UNIT_SECOND, 0, RIGHT )
end

-- Draw target time list on top right side area B
function vbase.drawTargetList( widget, task )
	lcd.font(FONT_L)
	local text_w, text_h = lcd.getTextSize("0")
	local nextVertLoc = 3
	for targetCount = 1, #task.TARGET_STRING_ARRAY do
		lcd.drawText( 5 + vbase.verticaldividerx, nextVertLoc, task.TARGET_STRING_ARRAY[targetCount] .. 's')
		nextVertLoc = nextVertLoc + text_h
	end
end

-- Draw the times list on top right side area B
function vbase.drawTimes( widget, task )
	lcd.font(FONT_L)
	text_w, text_h = lcd.getTextSize("0")
	
	local offset = vbase.verticaldividerx + (text_w*4) + (text_w/1.4)
	for i=0,task.COUNT - 1 do
		task.times.draw( offset, 3 + text_h*i, i+1, 0 )
	end
end

-- Draw the times Total at the bottom of the times list
function vbase.drawTimesTotal( widget, task )
	lcd.font(FONT_L)
	text_w, text_h = lcd.getTextSize("0")

	local offset = vbase.verticaldividerx + (text_w*4) + (text_w/1.4)
	local drawy = 3 + (text_h*task.COUNT)
	f3kDrawTimer( offset, drawy, task.times.getTotal(), 0 )
	lcd.drawText( offset + (text_w*5), drawy, "Total" )
end

-- draw note in the upper right corner
function vbase.drawNote( widget, noteText )
	local widget_w, widget_h = lcd.getWindowSize()
	lcd.font(FONT_S)
	local text_w, text_h = lcd.getTextSize(noteText .. "0")
	lcd.drawText( widget_w - vbase.f3kDashboardOffset - text_w + 5, 5, noteText )
end

-- draw common and all other things needed for AULD
function vbase.drawCommonAULD( widget, task )
	vbase.drawCommon( widget, task )
	vbase.drawTimes( widget, task )
	vbase.drawTimesTotal( widget, task )
	vbase.drawCurrent( widget, task )
end

-- draw common and all other things needed for last best
function vbase.drawCommonLastBest( widget, task )
	vbase.drawCommon( widget, task )
	vbase.drawPrepWorkTime( widget, task )
	vbase.drawTimes( widget, task )
	vbase.drawTimesTotal( widget, task )
end

-- For improve margin on bottom right area D
function vbase.drawImproveMargin( widget, task )
	local widget_w, widget_h = lcd.getWindowSize()
	widget_w = widget_w - vbase.f3kDashboardOffset
	lcd.font(FONT_L)
	text_w, text_h = lcd.getTextSize("0")
	if task.state == 4 then	-- landed
		if task.possibleImprovement > 0 then
			lcd.drawText( vbase.verticaldividerx + (text_w*1), text_h * (task.COUNT+2), 'Can improve: ' )
			f3kDrawTimer( vbase.verticaldividerx + (text_w*12), text_h * (task.COUNT+2), task.possibleImprovement, 0 )
		end
	end
end

return vbase
