print('init.lua ver 1.2')

-- GPIO MAP: http://goo.gl/RPzg80
PINS = {R = 7, G = 4, B = 6, W = 5} -- GPIOs: 13, 2, 12, 14
FREQHZ = 1000
DUTY   = 512
MAX = 1023
MIN = 0

DELAY = 5 -- startup delay

R,G,B,W = 0,0,0,0
RINC, GINC, BINC, WINC = 0,0,0,0

-- setup output GPIOs
for _, p in pairs(PINS) do
 gpio.mode(p, gpio.OUTPUT)
 pwm.setup(p, FREQHZ, DUTY)
 pwm.start(p)
end

-- 0-1023 values
function rgbw(r, g, b, w)
  r, g, b, w = r or -1, g or -1, b or -1, w or -1 
  if (r >= MIN) and (r <= MAX) then R = r pwm.setduty(PINS.R, R) end
  if (g >= MIN) and (g <= MAX) then G = g pwm.setduty(PINS.G, G) end
  if (b >= MIN) and (b <= MAX) then B = b pwm.setduty(PINS.B, B) end
  if (w >= MIN) and (w <= MAX) then W = w pwm.setduty(PINS.W, W) end
end

function on()
  rgbw(MAX,MAX,MAX,MAX)
end

function off()
  rgbw(MIN,MIN,MIN,MIN)
end

off() -- initial

-- save config.lua... used by auto-config script...
function save_config(ssid, pass)
  ssid, pass = ssid or '', pass or ''
  file.open("config.lua", "w")
  file.close()
  file.remove("config.lua")
  file.open("config.lua", "w+")
  file.writeline('CONFIG = {}')
  if (ssid ~= '') then file.writeline('CONFIG.SSID = "' .. ssid .. '"') end
  if (pass ~= '') then file.writeline('CONFIG.PASS = "' .. pass .. '"') end
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
CONFIG = CONFIG or {}
pcall(dofile, "config.lua")

if (CONFIG.SSID == nil) or (CONFIG.PASS == nil) then
  print('No config.  Loading connect.lua in ' .. DELAY .. ' seconds. enter "kill()" to stop')
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
  tmr.alarm(0, DELAY * 1000, 0, function() dofile('connect.lua') end)
else
  wifi.setmode(wifi.STATION)
  wifi.sta.config(CONFIG.SSID, CONFIG.PASS)
  print('Loading main.lua in ' .. DELAY .. ' seconds. enter "kill()" to stop')
  tmr.alarm(0, DELAY * 1000, 0, function() dofile('main.lua') end)
end
