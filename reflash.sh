#sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 9600 write_flash 0x00000 ../firmware/nodemcu_latest.bin
#sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 9600 write_flash 0x40000080 ../firmware/nodemcu_latest.bin
#sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash 0x40000080 ../firmware/nodemcu_latest.bin

#---- Linux

# Initial Flash of ESP-03's... After this, you can do the custom below...
#sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 9600 write_flash 0x00000 ../firmware/nodemcu_integer_0.9.5_20150318.bin

# Custom Built NodeMCU Master with required modules...
#sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 9600 write_flash 0x00000 ../firmware/NodeMCU\ Custom\ Build/nodemcu-master-9-modules-2015-08-10-01-56-53-integer.bin


#---- Mac

# Initial Flash of ESP-03's... After this, you can do the custom below...
#sudo python ../esptool/esptool.py --port /dev/cu.usbserial --baud 9600 write_flash 0x00000 ../firmware/nodemcu_integer_0.9.5_20150318.bin
#sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash 0x00000 ../firmware/nodemcu_integer_0.9.5_20150318.bin

# Custom Built NodeMCU Master with required modules...
#sudo python ../esptool/esptool.py --port /dev/cu.usbserial --baud 9600 write_flash 0x00000 ../firmware/NodeMCU\ Custom\ Build/nodemcu-master-9-modules-2015-08-10-01-56-53-integer.bin

sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash 0x00000 ../firmware/NodeMCU\ Custom\ Build/nodemcu-master-9-modules-2015-08-10-01-56-53-integer.bin


