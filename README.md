# F3K TRAINING

This is code originally by Mike (ON4MJ on rcgroups) with previous changes also by me to help convert it to a Widget for OpenTX.  It was then modified by Mattoia90 to include some newer f3k tasks as well as add some missing views.  None of that really matters with this forked version though as OpenTX is no longer working with this Ethos version.  A big thanks for all the work that was put into this over the years.  This new fork is a work in progress to get it working on the new FrSky Ethos Lua RC radios.  It currently requires an alpha build of Ethos 1.1.0 alpha 12 for it to work.

Only Free Flight and TaskA is working and it isn't pretty :)

Version 4.0.0 Work in progress for FrSky Ethos radios using the alpha builds available from FrSky.  It will likely take me a LONG LONG time to get it presentable and working as I still don't fully understand how it all works.  It has taken me way too many hours just to get Free Flight partially working and Ethos Lua is still in alpha testing and API changing weekly.

This version does not work with OpenTX as there were too many changes for me to understand how to make them work or to even know if it is possible to keep compatibility with OpenTX.

## INSTALL ON ETHOS Radio
1. Open SD card of your Ethos radio (the one with directories for models, scripts, etc)
2. Copy the F3K_TRAINING folder in the SCRIPTS folder on the SD card  ...\Scripts\F3K_TRAINING\
3. Copy the f3ktraining.lua also into the SCRIPTS folder  ...\Scripts\f3ktraining.lua

## CUSTOMIZE SWITCH
Once install, you can add the F3K Training widget to your model config and then configure it in the Widget config for the F3K Training widget.
This is how I configured the widget...
- Sim mode: disabled (that is for when it is running on the sim as os.clock() has different precision on the sim vs radio)
- Menu Select Switch Position: SD-
- Start Switch Position: SD down
- PreLaunch Switch Position: SI down
- Menu Scroll Analog: Throttle (no motor on DLGs as i use flaps for throttle)

## Changelog
- 4.0.0 alpha 1 - initial release
- 4.0.0 alpha 2 - No need to configure a simmode option to know if it is on the sim or the radio.  Removed getTime() wrapper function and simmode option.  Just use os.clock() directly so that precision is the same for sim and radio.
