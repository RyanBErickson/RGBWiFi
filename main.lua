-- TODO: If there is no ip address (i.e. no client found) for X times booting (persist the data), automatically reset to AP mode.

LOAD_DELAY = 1500

blinkstop()
blink(30,30,0,250) -- Red blink waiting for IP...

-- TODO: Look in to wifi.sta.eventMonReg() events... Then I can tell status in a more efficient manner.

-- Wait for IP Address availability...
tmr.alarm(0, 500, 1, function()   

  --led() -- blink LED 1/sec
  --rgbw(20,20)

  ip, nm, gw=wifi.sta.getip()
  if ip ~= nil then         
      blinkstop()

      print("\n------------------\n IP Address: ",ip,"\n Netmask: ",nm,"\n Gateway: ",gw)
      print("------------------")

      kill()
      --led("OFF")

      g(10) -- Green, got IP

      local delay = LOAD_DELAY

      -- Delay loading of udp.lua/tcp.lua to allow heap memory to recover...
      tmr.alarm(0, delay, 0, function() require('udp') g(30) end)
      delay = delay + LOAD_DELAY

      -- Delay loading of freq.lua to allow heap memory to recover...
      tmr.alarm(3, delay, 0, function() require('freq') g(50) end)
      delay = delay + LOAD_DELAY

      tmr.alarm(4, delay, 0, function() off() require('freq2') end)
      delay = delay + LOAD_DELAY
   end 
end)

print("Loaded main...")
