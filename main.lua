-- TODO: If there is no ip address (i.e. no client found) for X times booting (persist the data), automatically reset to AP mode.

LOAD_DELAY = 3000

blinkstop()
blink(30,30,0,250) -- Red blink waiting for IP...

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

      off()
      g(10) -- Green, got IP

      local delay = LOAD_DELAY

      -- Delay loading of udp.lua/tcp.lua to allow heap memory to recover...
      tmr.alarm(0, delay, 0, function() require('udp') g(30) end)
      delay = delay + LOAD_DELAY

      tmr.alarm(1, delay, 0, function() require('tcp') g(50) end)
      delay = delay + LOAD_DELAY
      --delay = delay + (LOAD_DELAY * 2)

      -- Delay loading of freq.lua to allow heap memory to recover...
      tmr.alarm(3, delay, 0, function() require('freq') g(70) end)
      delay = delay + LOAD_DELAY

      tmr.alarm(4, delay, 0, function() require('freq2') off() end)
      delay = delay + LOAD_DELAY
   end 
end)

print("Loaded main...")
