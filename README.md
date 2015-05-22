# RGBWiFi
ESP8266 RGBW LED Controller

NOTE: Commits after March 26th are no longer using the HTTP UI.  The current code uses UDP commands only.  Your mileage may vary if you want to use the HTTP version.

These are my current files for the RGBWifi project so far, including my 'obsolete' files that I was using when I was doing the Arduino with the ESP-01 as a co-processor.

It could use a good cleanup, it's got scripts I call to push it to the ESP, the squish configs I use, etc.

All you really need are the .lua files.

My system is using the ESP-03, which has 4 free GPIOs with no doubling-up or other tricks.  Wiring for the MOSFETs is basically how they show at Adafruit (https://learn.adafruit.com/rgb-led-strips/usage)

The 'setup code' in config.lua, which sets up an access point and lets you configure the device was taken from: https://github.com/dannyvai/esp2866_tools (and fitted for my own use).

The pretty HTML code (in index.html) was taken from: http://dangerousprototypes.com/forum/viewtopic.php?f=56&t=7026

For this to work, you may need to use the nodemcu 'Integer Numbers' firmware, and you need to load the following files on your ESP8266:

init.lua
connect.lua
main.lua
freq.lua
index.html
nodata.html

