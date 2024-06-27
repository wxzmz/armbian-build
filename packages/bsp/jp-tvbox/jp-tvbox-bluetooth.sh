#! /bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin
blue_mac=9d:ac:$(cat /sys/class/net/eth0/address | cut -d : -f 3-6)
modprobe hci_uart
modprobe rfcomm

killall brcm_patchram_plus

echo 0 > /sys/class/rfkill/rfkill0/state
sleep 2
echo 1 > /sys/class/rfkill/rfkill0/state
sleep 2

#brcm_patchram_plus  --bd_addr "9D:AC:DE:98:3C:15" --enable_hci --no2bytes --use_baudrate_for_download  --tosleep  200000 --baudrate 1500000 --patchram /lib/firmware/ /dev/ttyS1 &
brcm_patchram_plus  --bd_addr "$blue_mac" --enable_hci --no2bytes --use_baudrate_for_download  --tosleep  200000 --baudrate 1500000 --patchram /lib/firmware/ /dev/ttyS1 &
sleep 1
hciconfig hci0 up

echo ok

exit 0


