# F3K TRAINING for FrSky Ethos radios

Requires at least Ethos version 1.1.0.

Works with the following radios...
X20
X20S
X18
X18S
Twin X-Lite
Twin X-Lite S

If there is enough requests to get it working on the other older radios that work with Ethos like the X12S and X10, I will likely adapt it to work on those screens also.  Feel free to ping me on RCGroups (StatiC) if you want it work on those older radios with Ethos installed.

This is code originally by Mike (ON4MJ on rcgroups) with previous changes also by me to help convert it to a Widget for OpenTX.  It was then modified by Mattoia90 to include some newer f3k tasks as well as add some missing views.  With this forked version though, OpenTX is no longer working.  A big thanks for all the work that was put into this over the years.  This new fork is for the newer FrSky Ethos Lua RC radios.

One of the main reasons I like ON4MJ's script so much is that the menu is controlled via stick input to very quickly position it on the task you want and selecting tasks and starting the task using a switch.  No need to push buttons or touch the screen.  Launching is detected by holding and then at some point releasing the pre-launch switch position that you define.  I use button SI for that which is on the back of tthe transmitter.

This version does not work with OpenTX as there were too many changes for me to understand how to make them work or to even know if it is possible to keep compatibility with OpenTX.  This allowed some cleanup and redesign of the view files to create functions in viewbase so that only viewbase.lua needs to be different between radio screen sizes (and potentially in the future support smaller widget sizes more easily).

## INSTALL ON ETHOS Radio
1. Open SD card of your Ethos radio on your PC (the one with directories for models, scripts, etc)
2. Copy the F3K_TRAINING folder into the SCRIPTS folder on the SD card.  The directory should look like this assuming F: is your SD card...
- F:\Scripts\F3K_TRAINING\main.lua
- F:\Scripts\F3K_TRAINING\timer.lua
- ... etc

## CUSTOMIZE SWITCH
Once installed, you can add the F3K Training widget to your model config and then configure it in the Widget config for the F3K Training widget.
This is how I configured the widget...
- Menu Select Switch Position: SD-
- Start Switch Position: SD down
- PreLaunch Switch Position: SI down
- Menu Scroll Analog: Throttle (no motor on DLGs as i use flaps for throttle)

- Optionally set the RSSI and RxBattery sensor options to have them displayed on right hand side.  They default to sensors named RSSI and RxBatt which are defaults for FrSky sensors.
- Optionally set the VSpeed and Altitude sensor options to have launch height announced on the Free Flight task as well as list the launch height next to the history of flights on the Free Flight task.
- Optionally disable announcing launch height
