
gPINS = {R = 7, G = 4, B = 6, W = 5} 
PWMFREQHZ = 1000 -- hz (times/sec)
PWMDUTY = 512 -- Units???

for _, pin in pairs(gPINS) do
 gpio.mode(pin, gpio.OUTPUT)
 pwm.setup(pin, PWMFREQHZ, PWMDUTY)
 pwm.start(pin)
 pwm.setduty(pin, 0)
end

function rgbw(r, g, b, w)
  r, g, b, w = r or 0, g or 0, b or 0, w or 0
  pwm.setduty(gPINS.R, r) -- 0-1023 values...
  pwm.setduty(gPINS.G, g)
  pwm.setduty(gPINS.B, b)
  pwm.setduty(gPINS.W, w)
end

