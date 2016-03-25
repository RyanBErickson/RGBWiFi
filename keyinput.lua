function lightning()
  gLightning = gLightning or false
  if (gLightning) then return end
  gLightning = true
  local intensity = INTENSITY
  local r,g,b,w = cur.R,cur.G,cur.B,cur.W
  INTENSITY = 100
  for i=1, 5 do
    on() tmr.delay(10000) tmr.wdclr()
    off() tmr.delay(i*15000) tmr.wdclr()
  end
  INTENSITY = intensity
  rgbw(r,g,b,w)
  gLightning = false
end

function debounce (func)
    local last = 0
    local delay = 200000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

function onChange ()
  gPressCount = (gPressCount or 0) + 1
  if (gPressCount > 9) then
    lightning()
    reset()
  end
end

gpio.trig(3, 'down', debounce(onChange))

print("Loaded keyinput...")
