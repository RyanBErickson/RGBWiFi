
-- GPIO MAP: http://goo.gl/RPzg80
--local PINS = {R = 5, G = 6, B = 7, W = 4} -- GPIOs: 13, 2, 12, 14  -- RGB strip
local PINS = {R = 6, G = 5, B = 7, W = 4} -- GPIOs: 13, 2, 12, 14 (not in that order) -- RGBW strips

-- GAMMA brightness correction table... converts 0-100 to 0-1023 in a more eye-linear fashion.
GAMMA = {
1,1,1,1,1,1,2,2,3,4,
5,6,7,9,10,12,14,16,18,20,
23,25,28,31,34,38,41,45,49,53,
58,62,67,72,78,83,89,95,101,107,
114,121,128,136,143,151,159,168,176,185,
195,204,214,224,234,245,256,267,278,290,
302,314,327,340,353,367,380,395,409,424,
439,454,470,486,502,519,536,554,571,589,
608,626,645,665,684,704,725,746,767,788,
810,832,855,878,901,925,949,973,998,1023
}
GAMMA[0] = 0

MAX = 100
MIN = 0

local DELAY = 5 -- startup delay
R,G,B,W,INTENSITY = 0,0,0,0,50

-- setup output GPIOs
for _, p in pairs(PINS) do
 gpio.mode(p, gpio.OUTPUT)
 pwm.setup(p, 240, 0) -- FREQHZ, DUTY -- TODO: Do I need a higher frequency?  Would that help anything?
                         -- Probably anything over 120Hz is fine...

 pwm.start(p)
 pwm.setduty(p, 0)
end

function calcval(val)
  local v = tonumber(val) or -1
  local orig = v
  if (v >= MIN) and (v <= MAX) then
    v = GAMMA[(v * INTENSITY)/100]
  else
    return
  end
  return orig, v
end


function r(val)
  local v, v1 = calcval(val)
  if (v == nil) then return end
  R=v
  pwm.setduty(PINS.R, v1)
end

function g(val)
  local v, v1 = calcval(val)
  if (v == nil) then return end
  G=v
  pwm.setduty(PINS.G, v1)
end

function b(val)
  local v, v1 = calcval(val)
  if (v == nil) then return end
  B=v
  pwm.setduty(PINS.B, v1)
end

function w(val)
  local v, v1 = calcval(val)
  if (v == nil) then return end
  W=v
  pwm.setduty(PINS.W, v1)
end

red, green, blue, white = r, g, b, w

-- 0-100 values
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

function level(val)
  local i = tonumber(val) or -1
  if (i == -1) then return end
  INTENSITY = i
  if (INTENSITY > 100) then INTENSITY = 100 end
  if (INTENSITY < 0) then INTENSITY = 0 end
  rgbw(R,G,B,W)
end

local _c = "config"
function reset()
  file.open("config.lua", "w")
  file.close()
  node.restart()
end

-- Function to kill loading of code, incase of boot loop...
function kill() tmr.stop(0) end

-- load 'config.lua' file (if exists)...
C = {}
pcall(require, _c)

--local norepeat = 0
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

