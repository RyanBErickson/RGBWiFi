
-- Not for micro, run on local Lua to calculate lookup table...
function memoize(fn)
  local t = {}
  return function(x)
    local y = t[x]
    if y == nil then y = fn(x); t[x] = y end
    return y
  end
end

function _fact(n)
  if (n == 0) then
    return 1
  else
    return n * _fact(n - 1)
  end
end

fact = memoize(_fact)

-- Taylor series approximation of y=sin(x)
function _t_sin(x)
  return x - (x^3/fact(3)) 
           + (x^5/fact(5)) 
           - (x^7/fact(7)) 
           + (x^9/fact(9))
           - (x^11/fact(11))
           + (x^13/fact(13))
           - (x^15/fact(15))
           + (x^17/fact(17))
           - (x^19/fact(19))
           + (x^21/fact(21))
           - (x^23/fact(23))
           + (x^25/fact(25))
end

t_sin = _t_sin
--t_sin = memoize(_t_sin)

-- TODO: Map *any* value onto the first quadrant values of sin...
-- * sin(x) = - sin(-x), to map from quadrant IV to I
-- * sin(x) = sin(pi - x), to map from quadrant II to I
-- * to map from quadrant III to I, apply both identities, i.e. sin(x) = - sin (pi + x)

local pi = 3.1415926
local pi2 = pi * 2 -- 2pi (full circle)

function sin(x)
  x = x % pi2 -- mod 2pi

  -- Determine quadrant...
  if (x > 0     ) and (x <=   pi/2) then return t_sin(x) end       -- Q1 (0-1pi/2)
  if (x >   pi/2) and (x <=   pi  ) then return t_sin(pi - x) end  -- Q2 (1-2pi/2)
  if (x >   pi  ) and (x <= 3*pi/2) then return -t_sin(pi + x) end -- Q3 (2-3pi/2)
  if (x > 3*pi/2) and (x <= 2*pi  ) then return -t_sin(-x) end     -- Q4 (3-4pi/2)
  return t_sin(x)
end

freq = .3
ampl = 500
cent = 500

local val1 = 2*pi/3
local val2 = 4*pi/3

-- Scene 1
function S1(i)
  local r = math.floor(math.sin(freq*i       ) * ampl + cent + .5)
  local g = math.floor(math.sin(freq*i + val1) * ampl + cent + .5)
  local b = math.floor(math.sin(freq*i + val2) * ampl + cent + .5)
  --local r = sin(freq*i       ) * ampl + cent
  --local g = sin(freq*i + val1) * ampl + cent
  --local b = sin(freq*i + val2) * ampl + cent
  return r, g, b
end

--freq = .3 for i=0, 32 do R, G, B = S1(i) print(R,G,B) rgbw(R,G,B) tmr.wdclr() end
--freq = .063 for i=0, 100 do R, G, B = S1(i) print(R,G,B) rgbw(R,G,B) tmr.delay(30) tmr.wdclr() end
-- freq = .063 for i=0, 100 do print(S1(i)) end
--freq = .0063 i = 0 tmr.alarm(1, 30, 1, function() i = i + 1 if (i > 1000) then tmr.stop(1) end R, G, B = S1(i) print(R,G,B) rgbw(R,G,B) tmr.wdclr() end)

