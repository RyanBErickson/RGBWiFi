
-- GPIO MAP: http://goo.gl/RPzg80
-- Mapping between GPIOX and NodeMCU 'pin'
GPIO = {10, 4, 9, 2, 1, nil, nil, nil, 11, 12, nil, 6, 7, 5, 8, 0} -- 1-16
GPIO[0] = 3 -- 0

-- My boards, 2 different RGBW strips...
local PINS = {R = GPIO[14], G = GPIO[12], B = GPIO[13], W = GPIO[2]}
--local PINS = {R = GPIO[12], G = GPIO[14], B = GPIO[13], W = GPIO[2]} -- R/G reversed

-- H801 WiFi controller, W2 = GPIO[2], RLED = GPIO[5], GLED = GPIO[1] (used for TX)}
--local PINS = {R = GPIO[15], G = GPIO[13], B = GPIO[12], W = GPIO[14]} 
RLED = GPIO[5]

gpio.mode(RLED, gpio.OUTPUT)

function led(strCmd)
  strCmd = strCmd or "" -- toggle default
  if (strCmd == "ON") then
    gpio.write(RLED, gpio.LOW)
  elseif (strCmd == "OFF") then
    gpio.write(RLED, gpio.HIGH)
  else
    local val = 0 if (gpio.read(RLED) == 0) then val = 1 end
    gpio.write(RLED, val)
  end
end

-- Don't enable blinky LED for my boards...
led = function() end

led("OFF")


cur = {R = 0, G = 0, B = 0, W = 0}


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
INTENSITY = 50

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


function c(val, C)
  local v, v1 = calcval(val)
  if (v == nil) then return end
  cur[C]=v
  pwm.setduty(PINS[C], v1)
end

function r(v) c(v, "R") end
function g(v) c(v, "G") end
function b(v) c(v, "B") end
function w(v) c(v, "W") end

red, green, blue, white = r, g, b, w

-- 0-100 values
function rgbw(r, g, b, w)
  red(r)
  green(g)
  blue(b)
  white(w)
end

function on()
  tmr.stop(1) tmr.stop(3) tmr.stop(4) tmr.stop(5) tmr.stop(6)
  rgbw(MAX,MAX,MAX,MAX)
end

function off()
  tmr.stop(1) tmr.stop(3) tmr.stop(4) tmr.stop(5) tmr.stop(6)
  rgbw(MIN,MIN,MIN,MIN)
end

function level(val)
  local i = tonumber(val) or -1
  if (i == -1) then return end
  INTENSITY = i
  if (INTENSITY > 100) then INTENSITY = 100 end
 if (INTENSITY < 0) then INTENSITY = 0 end
  rgbw(cur.R,cur.G,cur.B,cur.W)
end

function blinkstop()
  tmr.stop(2)
  off()
  _cur = 0
  _blink = 2
end

function blink(r, g, b, rate, max)
  _blink = _blink or 2
  max = max or 25
  if (_blink == 2) then
    _blink = 0
    _max = max
    _cur = 0
    tmr.alarm(2, rate, 1, function() blink(r,g,b) end)
  end

  if (_blink == 0) then
    _cur = _cur + 1
    if (_cur > _max) then off() blinkstop() end
    rgbw(r,g,b,0)
    _blink = 1
  else
    off()
    _blink = 0
  end
end

-- save or clear config.lua... 
function config(ssid, pass)
  ssid, pass = ssid or '', pass or ''
  file.open("config.lua", "w")
  file.close()
  file.remove("config.lua")
  if (ssid ~= '') then
    file.open("config.lua", "w+")
    file.writeline('C = {}')
    file.writeline('C.SSID = "' .. ssid .. '"')
    if (pass ~= '') then file.writeline('C.PASS = "' .. pass .. '"') end
    file.flush()
    file.close()
  end
end

-- Function to kill loading of code, incase of boot loop...
function kill() tmr.stop(0) tmr.stop(1) tmr.stop(2) tmr.stop(3) tmr.stop(4) end


-- load 'config.lua' file (if exists)...
C = {}
pcall(require, 'config')

-- Show LED blink per second...
tmr.alarm(1, 500, 1, function() led() end)
blink(0,0,20,500) -- Red blink before load...

if (C.SSID == nil) or (C.PASS == nil) then
  print('Config setup in ' .. DELAY .. 's. "kill()" to stop')
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
  tmr.alarm(0, DELAY * 1000, 0, function() tmr.stop(1) require('keyinput') require('connect') end)
else
  wifi.setmode(wifi.STATION)
  wifi.sta.config(C.SSID, C.PASS)
  print('Starting in ' .. DELAY .. 's. "kill()" to stop')
  tmr.alarm(0, DELAY * 1000, 0, function() tmr.stop(1) require('keyinput') require('main') end)
end
C = nil

