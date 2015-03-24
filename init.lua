print('init.lua ver 1.2')

-- GPIO MAP: http://goo.gl/RPzg80
local PINS = {R = 7, G = 4, B = 6, W = 5} -- GPIOs: 13, 2, 12, 14
local FREQHZ = 1000
local DUTY   = 512
local MAX = 1023
local MIN = 0

local DELAY = 5 -- startup delay
R,G,B,W = 0,0,0,0

-- setup output GPIOs
for _, p in pairs(PINS) do
 gpio.mode(p, gpio.OUTPUT)
 pwm.setup(p, FREQHZ, DUTY)
 pwm.start(p)
end

-- 0-1023 values
function rgbw(r, g, b, w)
  local inten = ((gIntensity or 5) / 10)
  r, g, b, w = r or -1, g or -1, b or -1, w or -1 
  if (r >= MIN) and (r <= MAX) then R=r pwm.setduty(PINS.R, r*inten) end
  if (g >= MIN) and (g <= MAX) then G=g pwm.setduty(PINS.G, g*inten) end
  if (b >= MIN) and (b <= MAX) then B=b pwm.setduty(PINS.B, b*inten) end
  if (w >= MIN) and (w <= MAX) then W=w pwm.setduty(PINS.W, w*inten) end
end

function on()
  rgbw(MAX,MAX,MAX,MAX)
end

function off()
  rgbw(MIN,MIN,MIN,MIN)
end

off() -- initial

-- save config.lua... used by auto-config script...
local _c = "config.lua"
function save_config(ssid, pass)
  ssid, pass = ssid or '', pass or ''
  file.open(_c, "w")
  file.close()
  file.remove(_c)
  file.open(_c, "w+")
  file.writeline('C = {}')
  if (ssid ~= '') then file.writeline('C.SSID = "' .. ssid .. '"') end
  if (pass ~= '') then file.writeline('C.PASS = "' .. pass .. '"') end
  file.flush()
  file.close()
end

function reset()
  save_config()
  node.restart()
end

-- Function to kill loading of code, incase of boot loop...
function kill() tmr.stop(0) end

-- load 'config.lua' file (if exists)...
C = {}
pcall(dofile, _c)

if (C.SSID == nil) or (C.PASS == nil) then
  print('Config setup in ' .. DELAY .. 's. "kill()" to stop')
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
  tmr.alarm(0, DELAY * 1000, 0, function() dofile('connect.lua') end)
else
  wifi.setmode(wifi.STATION)
  wifi.sta.config(C.SSID, C.PASS)
  print('Starting in ' .. DELAY .. 's. "kill()" to stop')
  tmr.alarm(0, DELAY * 1000, 0, function() dofile('main.lua') end)
end
C = nil

