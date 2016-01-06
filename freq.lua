
-- 3,4,5,6 are timers for R,G,B,W
tmrid = {} tmrid[r] = 3 tmrid[g] = 4 tmrid[b] = 5 tmrid[w] = 6


function stopramp(c)
  local tid = tmrid[c]
  tmr.stop(tid)
end


function rampcolor(lev, timems, c, C)
  lev = tonumber(lev) or -1
  if (lev == -1) then return end
  if (lev < 0) then lev = 0 end
  if (lev > 100) then lev = 100 end
  timems = tonumber(timems) or -1
  if (timems == -1) then return end
  if (timems < 1) then timems = 1 end

  -- changing 'level', not a color...
  if (C == nil) then
    level(lev)
    return
  end

  local diff = lev - C
  if (diff == 0) then return end -- already at level...

  local tm = timems / math.abs(diff)

  if (tm < 10) then tm = 10 end
  local step = diff / (timems / tm)

  -- slower than 1 step per time, need to increase time to match slowest per step...
  if (step == 0) then
    step = 1
    tm = timems / diff
  end

  local tid = tmrid[c]

  print("l: " .. lev .. " c: " .. C .. " d: " .. diff .. " tm: " .. tm .. " st: " .. step)
  tmr.alarm(tid, tm, 1, function() 
                        tmr.wdclr()
                        C=C+step 

                        if (C > 100) or (C < 0) then tmr.stop(tid) end

                        if ((step > 0) and (C>=lev)) or ((step < 0) and (C<=lev)) then 
                          tmr.stop(tid) 
                          c(lev) -- Ensure we end at 'final' level...
                        end 
                        c(C) 
                      end)
end


function f_scene()
  _i = _i or 0
  _i = _i + 1 rgbw(freq(_i%200), freq((_i+33)%200), freq((_i+66)%200))
  --_i = _i + 1 rgbw(freq(_i%200)) -- Only showing RED for simplicity at this point... should cycle 50-100-50-0-50...
end

--local repeat = 1
function scene(scene)
  _i=0
  f_scene()
  if (scene == 1) then
    tmr.alarm(1,30,1,f_scene)
  elseif (scene == 2) then
    tmr.alarm(1,300,1,f_scene)
  elseif (scene == 3) then
    tmr.alarm(1,3000,1,f_scene)
  end
end

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


print("Loaded Freq...")
