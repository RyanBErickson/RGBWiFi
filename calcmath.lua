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
end

t_sin = memoize(_t_sin)

-- TODO: Map *any* value onto the first quadrant values of sin...
-- * sin(x) = - sin(-x), to map from quadrant IV to I
-- * sin(x) = sin(pi - x), to map from quadrant II to I
-- * to map from quadrant III to I, apply both identities, i.e. sin(x) = - sin (pi + x)
sin = t_sin

