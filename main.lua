-- TODO: If there is no ip address (i.e. no client found) for X times booting (persist the data), automatically reset to AP mode.

LOAD_DELAY = 3000

-- Wait for IP Address availability...
tmr.alarm(0, 500, 1, function()   

  led() -- blink LED 1/sec

  ip, nm, gw=wifi.sta.getip()
  if ip ~= nil then         
      print("\n------------------\n IP Address: ",ip,"\n Netmask: ",nm,"\n Gateway: ",gw)
      print("------------------")
      tmr.stop(0) tmr.stop(1) tmr.stop(2) tmr.stop(3)
      led("OFF")

      local delay = LOAD_DELAY

      -- Delay loading of udp.lua/tcp.lua to allow heap memory to recover...
      tmr.alarm(0, delay, 0, function() require('udp') end)
      delay = delay + LOAD_DELAY

      tmr.alarm(1, delay, 0, function() require('tcp') end)
      delay = delay + (LOAD_DELAY * 2)

      -- Delay loading of freq.lua to allow heap memory to recover...
      tmr.alarm(2, delay, 0, function() require('freq') end)
      delay = delay + LOAD_DELAY

      tmr.alarm(3, delay, 0, function() require('freq2') end)
      delay = delay + LOAD_DELAY
   end 
end)

print("Loaded main...")
