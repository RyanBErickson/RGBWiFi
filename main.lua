LOAD_DELAY = 1500

blinkstop()
blink(30,30,0,250) -- Red blink waiting for IP...

-- Wait for IP Address availability...
gIPAddress = ""
tmr.alarm(0, 500, 1, function()   

  ip, nm, gw=wifi.sta.getip()
  if ip ~= nil then         
    print("\n------------------\n IP Address: ",ip,"\n Netmask: ",nm,"\n Gateway: ",gw)
    print("------------------")

    tmr.stop(0)
    gIPAddress = ip
  end 
end)

local delay = LOAD_DELAY * 3

-- Delay loading of udp.lua/tcp.lua to allow heap memory to recover...
tmr.alarm(0, delay, 0, function() require('udp') end)
delay = delay + LOAD_DELAY

-- Delay loading...
tmr.alarm(1, delay, 0, function() require('http') end)
delay = delay + LOAD_DELAY

-- Delay loading of freq.lua to allow heap memory to recover...
tmr.alarm(3, delay, 0, function() require('freq') g(50) end)
delay = delay + LOAD_DELAY

tmr.alarm(4, delay, 0, function() off() require('freq2') end)

print("Loaded main...")
