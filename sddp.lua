
gSDDPMSG = [[NOTIFY __MSG_TYPE__ SDDP/1.0
Host: "rgbwifi-0123456"
From: "192.168.29.102:1902"
Max-Age: 3600
Type: "rbe:rgbwifi"
Primary-Proxy: "light"
Proxies: "light"
Manufacturer: "RyanE"
Model: "RGBWifi"
Driver: "rgbwifi.c4i"
]]

gSDDP = net.createConnection(net.UDP, false)
gSDDP:connect(1902, "239.255.255.250")

function SendSDDP(msgtype)
  msgtype = msgtype or "ALIVE"
  local msg = gSDDPMSG:gsub("__MSG_TYPE__", msgtype)
  gSDDP:send(msg)
end

