
-- GPIO MAP: http://goo.gl/RPzg80
--local PINS = {R = 5, G = 6, B = 7, W = 4} -- GPIOs: 13, 2, 12, 14  -- RGB strip
local PINS = {R = 6, G = 5, B = 7, W = 4} -- GPIOs: 13, 2, 12, 14 (not in that order) -- RGBW strips


local MAX = 1023
local MIN = 0

local DELAY = 5 -- startup delay
R,G,B,W,INTENSITY = 0,0,0,0,50

-- setup output GPIOs
for _, p in pairs(PINS) do
 gpio.mode(p, gpio.OUTPUT)
 pwm.setup(p, 1000, 512) -- FREQHZ, DUTY
 pwm.start(p)
 pwm.setduty(p, 0)
end

function r(val)
  local r = val or -1
  if (r >= MIN) and (r <= MAX) then R=r pwm.setduty(PINS.R, r*INTENSITY/100) end
end

function g(val)
  local g = val or -1
  if (g >= MIN) and (g <= MAX) then G=g pwm.setduty(PINS.G, g*INTENSITY/100) end
end

function b(val)
  local b = val or -1
  if (b >= MIN) and (b <= MAX) then B=b pwm.setduty(PINS.B, b*INTENSITY/100) end
end

function w(val)
  local w = val or -1
  if (w >= MIN) and (w <= MAX) then W=w pwm.setduty(PINS.W, w*INTENSITY/100) end
end

red, green, blue, white = r, g, b, w

-- 0-1023 values
function rgbw(r, g, b, w)
  red(r)
  green(g)
  blue(b)
  white(w)
end

function on()
  tmr.stop(1)
  rgbw(MAX,MAX,MAX,MAX)
end

function off()
  tmr.stop(1)
  rgbw(MIN,MIN,MIN,MIN)
end

function level(i)
  INTENSITY = tonumber(i) or 0
  if (INTENSITY > 100) then INTENSITY = 100 end
  if (INTENSITY < 0) then INTENSITY = 0 end
  rgbw(R,G,B,W)
end

local _c = "config"
function reset()
  file.open(_c, "w")
  file.close()
  node.restart()
end

-- Function to kill loading of code, incase of boot loop...
function kill() tmr.stop(0) end

-- load 'config.lua' file (if exists)...
C = {}
pcall(require, _c)

if (C.SSID == nil) or (C.PASS == nil) then
  print('Config setup in ' .. DELAY .. 's. "kill()" to stop')
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
  tmr.alarm(0, DELAY * 1000, 0, function() require('connect') end)
else
  wifi.setmode(wifi.STATION)
  wifi.sta.config(C.SSID, C.PASS)
  print('Starting in ' .. DELAY .. 's. "kill()" to stop')
  tmr.alarm(0, DELAY * 1000, 0, function() require('main') end)
end
C = nil

