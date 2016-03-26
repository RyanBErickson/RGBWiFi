
-- Used to identify this particular unit from many...
function indicate()
  gIndicate = gIndicate or false
  if (gIndicate) then return end
  gIndicate = true
  local intensity,r,g,b,w = INTENSITY,cur.R,cur.G,cur.B,cur.W
  -- Ramp White intensity up to indicate this node is being 'selected'
  for i=0, 50, 2 do
    INTENSITY = i
    rgbw(0, 0, 0, 100)
    tmr.delay(10000)
    tmr.wdclr()
  end
  INTENSITY = intensity
  rgbw(r,g,b,w)
  gIndicate = false
end

local F = {
0,3,6,9,12,15,18,21,24,27,30,
33,36,39,42,45,48,50,53,56,58,
61,63,66,68,70,72,75,77,79,80,
82,84,86,87,89,90,91,92,94,95,
96,96,97,98,98,99,99,99,99,99,
}
F[0] = 0


-- i == 0-200, but only data values for 1-50 (4 quadrants... we're only using data from Q1...)
-- (x2)
function freq(i)
  if (i == 0) then i = 1 end -- hack
  if (i > 199) then i = 1 end

  -- Handle 4 quadrant data...
  if (i >= 1) and (i <= 50)  then val = 50+F[i] / 2 end
  if (i > 50) and (i <= 100) then val = 50+F[50-(i-50)] / 2 end
  if (i > 100) and (i <= 150) then val = 50-F[(i-100)]/2 end
  if (i > 150) and (i <= 200) then val = 50-F[50-(i-150)]/2 end

  return val
end

print("Loaded Freq2...")
blink(0,100,0,50,2)


-- Blink out the IP Address of the system...
function enumerate(ip)
  local blinkrate = 500

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

tmr.alarm(0, 1500, 0, function() enumerate(ip) end) 


