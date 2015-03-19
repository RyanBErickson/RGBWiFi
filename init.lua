print('init.lua ver 1.2')

-- Setup output pins...
gPINS = {R = 7, G = 4, B = 6, W = 5} 
PWMFREQHZ = 1000
PWMDUTY = 512 -- ?

DELAY = 5 -- secs to delay start

local _g, _o, _sd = gpio, gpio.OUTPUT, pwm.setduty
R,G,B,W = 0,0,0,0
RINC, GINC, BINC, WINC = 0,0,0,0

for _, pin in pairs(gPINS) do
 _g.mode(pin, _o)
 pwm.setup(pin, PWMFREQHZ, PWMDUTY)
 pwm.start(pin)
end

-- 0-1023 values
function rgbw(r, g, b, w)
  r, g, b, w = r or -1, g or -1, b or -1, w or -1 
  if (r >= 0) and (r < 1024) then R = r _sd(gPINS.R, R) end
  if (g >= 0) and (g < 1024) then G = g _sd(gPINS.G, G) end
  if (b >= 0) and (b < 1024) then B = b _sd(gPINS.B, B) end
  if (w >= 0) and (w < 1024) then W = w _sd(gPINS.W, W) end
end

function on()
  rgbw(1023,1023,1023,1023)
end

function off()
  rgbw(0,0,0,0)
end

off()

-- Rewriting config.lua... to use in auto-config script...
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
  print('No config found.  Loading connect.lua in ' .. DELAY .. ' seconds. enter "kill()" to stop')
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.setip({ip = "192.168.1.1", gateway = "192.168.1.1", netmask = "255.255.255.0"})
  tmr.alarm(0, DELAY * 1000, 0, function() dofile('connect.lua') end)
else
  wifi.setmode(wifi.STATION)
  wifi.sta.config(CONFIG.SSID, CONFIG.PASS)
  print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=')
  print('MAC: ',wifi.sta.getmac())
  print('chip: ',node.chipid())
  print('heap: ',node.heap())
  print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=')
  print('Loading main.lua in ' .. DELAY .. ' seconds. enter "kill()" to stop')
  tmr.alarm(0, DELAY * 1000, 0, function() dofile('main.lua') end)
end

