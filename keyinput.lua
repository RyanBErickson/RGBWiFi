function lightning()
  gLN = gLN or false
  if (gLN) then return end
  gLN = true

  local i = INTENSITY
  local r,g,b,w = cur.R,cur.G,cur.B,cur.W
  INTENSITY = 100
  for j=1, 5 do
    on() tmr.delay(10000) tmr.wdclr()
    off() tmr.delay(j*15000) tmr.wdclr()
  end
  INTENSITY = i
  rgbw(r,g,b,w)
  gLN = nil
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
    config() -- reset config
    lightning()
    node.restart()
  end
end

gpio.trig(3, 'down', debounce(onChange))

print("Loaded keyinput...")
