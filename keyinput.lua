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


-- Blink out the IP Address of the system...
function enumerate(ip)
  local blinkrate = 500
  ip = ip or ""
  if (ip == "") then return end

  local _,_,lastip = ip:find("%d+%.%d+%.%d+%.(%d+)")
  local nums = {}
  for i = 1, #lastip do
    local num = tonumber(lastip:sub(i,i))
    if (num) then
      table.insert(nums,tonumber(lastip:sub(i,i)))
    end
  end

  blink(50,0,0,blinkrate,nums[1] or 0,
    function() blink(0,50,0,blinkrate,nums[2] or 0,
      function() blink(0,0,50,blinkrate,nums[3] or 0) end)
    end)
end


function debounce (func)
    local last = 0
    local delay = 8000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end


function onChange ()
  local val = gpio.read(3)
  if (val == 1) then return end  -- Ignore releases...

  _lastcount = _lastcount or 0
  _count = (_count or 0) + 1
  local diff = tmr.now() - _lastcount
  local abs = math.abs(diff)
  _lastcount = tmr.now()

  -- If it's not the first time, and there's a delay large enough for a 'pause', restart count.
  if (abs > 2000000) then
    _count = 0
  end

  if (_count == 3) then enumerate(ip) end

  if (_count > 9) then
    config() -- reset config
    lightning()
    node.restart()
  end
end

gpio.trig(3, 'down', debounce(onChange))

print("Loaded keyinput...")
