print('init.lua ver 1.2')

-- Setup output pins...
gPINS = {R = 7, G = 4, B = 6, W = 5} 
PWMFREQHZ = 1000
PWMDUTY = 512 -- ?

local g, o = gpio, gpio.OUTPUT

for _, pin in pairs(gPINS) do
 g.mode(pin, o)
 pwm.setup(pin, PWMFREQHZ, PWMDUTY)
 pwm.start(pin)
 pwm.setduty(pin, 0)
end

-- 0-1023 values
function rgbw(r, g, b, w)
  r, g, b, w = r or 0, g or 0, b or 0, w or 0
  pwm.setduty(gPINS.R, r)
  pwm.setduty(gPINS.G, g)
  pwm.setduty(gPINS.B, b)
  pwm.setduty(gPINS.W, w)
end

rgbw()

wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')')
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())
-- wifi config start
wifi.sta.config("***REMOVED***","***REMOVED***")
-- wifi config end
print("wifi config done.")

