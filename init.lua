print('init.lua ver 1.2')

-- Setup output pins...
gPINS = {R = 7, G = 4, B = 6, W = 5} 
PWMFREQHZ = 1000
PWMDUTY = 512 -- ?

local _g, _o, _sd = gpio, gpio.OUTPUT, pwm.setduty
r, g, b, w = 0, 0, 0, 0

for _, pin in pairs({4,5,6,7}) do
 _g.mode(pin, _o)
 pwm.setup(pin, PWMFREQHZ, PWMDUTY)
 pwm.start(pin)
end

-- 0-1023 values
function rgbw(r, g, b, w)
  r, g, b, w = r or 0, g or 0, b or 0, w or 0
  _sd(gPINS.R, r)
  _sd(gPINS.G, g)
  _sd(gPINS.B, b)
  _sd(gPINS.W, w)
end

rgbw()

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


function reset_wifi()
  save_config()
  node.restart()
end

-- Functions to kill loading of code, incase of boot loop...
function kill() tmr.stop(0) end
abort = kill


function prl(f, t)
  print('loading ' .. f .. '.lua in ' .. t .. ' seconds')
  tmr.alarm(0, t * 1000, 1, mkf(f, t))
end

function mkf(f, t)
  return function() 
            print('loading ' .. f ..'.lua...') 
            tmr.stop(0)
            pcall(dofile, f .. '.lua') end
end

-- wifi config start... Only do if we already have it... If not, do 'auto-discovery'
-- load 'config.lua' file...
pcall(dofile, "config.lua")
CONFIG = CONFIG or {}

if (CONFIG.SSID == nil) or (CONFIG.PASS == nil) then
  prl('connect', 15)
else
  wifi.setmode(wifi.STATION)
  wifi.sta.config(CONFIG.SSID, CONFIG.PASS)

  print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=')
  print('MODE: '..wifi.getmode())
  print('MAC: ',wifi.sta.getmac())
  print('chip: ',node.chipid())
  print('heap: ',node.heap())
  print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=')

  prl('main', 10)
end

