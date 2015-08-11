-- freq = .0635 print("F = {}") for i = 1, 99 do R = S1(i) print("F[" .. i .. "] = " .. R) end

-- TODO: can get away with higher resolution and less data if I go all 4 quadrants...
local F = { 32, 63, 95, 126, 156, 186, 215, 243, 270, 297, 322, 345, 
367, 388, 407, 425, 441, 455, 467, 478, 486, 492, 497, 499, 500, 498, 
495, 489, 482, 472, 461, 448, 433, 416, 398, 377, 356, 333, 309, 283, 
256, 228, 200, 170, 140, 109, 78, 47, 15, 8}

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
  local r,g,b,w = R,G,B,W
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
