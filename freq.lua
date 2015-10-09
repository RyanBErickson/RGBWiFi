-- freq = .0635 print("F = {}") for i = 1, 99 do R = S1(i) print("F[" .. i .. "] = " .. R) end

-- NOTE: None of this is going to work with gamma-corrected 0-100 values...



-- TODO: can get away with higher resolution and less data if I go all 4 quadrants...
local F = { 32, 63, 95, 126, 156, 186, 215, 243, 270, 297, 322, 345, 
367, 388, 407, 425, 441, 455, 467, 478, 486, 492, 497, 499, 500, 498, 
495, 489, 482, 472, 461, 448, 433, 416, 398, 377, 356, 333, 309, 283, 
256, 228, 200, 170, 140, 109, 78, 47, 15, 8}

-- 3,4,5,6 are timers for R,G,B,W
tmrid = {} tmrid[r] = 3 tmrid[g] = 4 tmrid[b] = 5 tmrid[w] = 6

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

  print("lev: " .. lev .. " cur: " .. C .. " diff: " .. diff .. " tm: " .. tm .. " step: " .. step .. " tid: " .. tostring(tid))
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

function freq(i)
  if (i == 0) then i = 1 end -- hack
  -- Handle 2 quadrant data...
  if (i > 99) then i = 99 end
  if (i > 50) then return 500-F[i-50] end
  return F[i] + 500
end

function f_scene()
  _i = _i or 0
  _i = _i + 1 rgbw(freq(_i%99), freq((_i+33)%99), freq((_i+66)%99))
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

print("Loaded Freq...")
