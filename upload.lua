#!/usr/bin/env lua

-- Fast UDP file uploader...
-- Pass in filename, 'uploaded' filename, and -r or --restart to restart the node.

ESP_HOST = "192.168.29.101"
--ESP_HOST = "192.168.29.102"
ESP_PORT = 8123

socket = require("socket")

udp = socket.udp()
udp:settimeout(2)
udp:setpeername(ESP_HOST, ESP_PORT)

local fname = arg[1] or ""
local savename = arg[2] or fname
local restart = arg[3] or ""

if (fname == "") then print("No filename(s) given.") return end

local f = io.open(fname, "r")
if (f == nil) then print("File not found: " .. fname) return end
f:close()

function SendData(dta)
  udp:send(dta .. "\r\n")
  while true do
    local data = udp:receive()
    if (data == nil) then
      print("Failed.")
      os.exit()
    end
    if (data:find('OK')) then
      print(dta .. " --> OK")
      break;
    end
  end
end

SendData([=[print('Uploading ]=] .. fname .. [=[')]=])

SendData([=[file.open("]=] .. savename .. [=[", "w")]=])
SendData([=[file.close()]=])
SendData([=[file.remove("]=] .. savename .. [=[")]=])
SendData([=[file.open("]=] .. savename .. [=[", "w+")]=])
for line in io.lines(fname) do
  SendData([=[file.writeline([==[]=] .. line .. [=[]==])]=])
end
SendData([=[file.flush()]=])
SendData([=[file.close()]=])

--SendData([=[print('Compiling...')]=])
--SendData([=[node.compile(']=] .. savename .. [=[')]=])
--SendData([=[file.remove(']=] .. savename .. [=[')]=])
SendData([=[print('Done...')]=])

if (restart == "--restart") or (restart == "-r") then
  SendData([=[print('Restarting...')]=])
  udp:send("node.restart()\r\n")
end

