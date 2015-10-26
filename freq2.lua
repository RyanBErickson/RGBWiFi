
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

print("Loaded Freq2...")
