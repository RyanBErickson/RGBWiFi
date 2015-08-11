#sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 9600 write_flash 0x00000 ../firmware/nodemcu_latest.bin
#sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 9600 write_flash 0x00000 ../firmware/nodemcu_integer_0.9.5_20150318.bin
sudo python ../esptool/esptool.py --port /dev/ttyUSB0 --baud 9600 write_flash 0x00000 ../firmware/NodeMCU\ Custom\ Build/nodemcu-master-9-modules-2015-08-10-01-56-53-integer.bin
