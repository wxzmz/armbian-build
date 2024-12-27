# Yijiahe JM10-3588 Rockchip RK3588 Octa core 4GB-32GB eMMC GBE HDMI PCIe SATA USB3 WiFi 4G 5G
BOARD_NAME="Yijiahe JM10-3588"
BOARDFAMILY="rockchip-rk3588"
BOOT_SOC="rk3588"
BOARD_MAINTAINER="r-mt"
KERNEL_TARGET="legacy,vendor"
BOOTCONFIG="rk3588_defconfig"
BOOT_FDT_FILE="rockchip/rk3588-yjh-jm10.dtb"
BOOT_LOGO="desktop"
FULL_DESKTOP="yes"
#硬改dsa交换机 设置 JM10_DSA_88E6390="yes" 内核版本这里使用vendor 6.1x, legacy 5.10内核未测试
#./compile.sh BOARD=yjh-jm10-3588 BRANCH=vendor BUILD_DESKTOP=no BUILD_MINIMAL=yes KERNEL_CONFIGURE=no RELEASE=noble JM10_DSA_88E6390=yes
JM10_DSA_88E6390="no"
IMAGE_PARTITION_TABLE="gpt"
ENABLE_EXTENSIONS="mesa-vpu"
# SRC_EXTLINUX="yes"
# SRC_CMDLINE="rootwait earlycon=uart8250,mmio32,0xfeb50000 console=ttyFIQ0 irqchip.gicv3_pseudo_nmi=0 rootfstype=ext4"

function post_family_config__nas-lite_kernel() {
	display_alert "$BOARD" "mainline BOOTPATCHDIR" "info"	
	if [[ ${BRANCH} = "legacy" ]] ; then
		KERNELPATCHDIR="rockchip-5.10-yjh-jm10"
	else
		KERNELPATCHDIR="rockchip-6.1-yjh-jm10"
	fi	
}

function post_family_tweaks_bsp__JM10-3588() {
	display_alert "$BOARD" "Installing rk3588-bluetooth.service" "info"

	# Bluetooth on this board is handled by a Broadcom (AP6275PR3) chip and requires
	# a custom brcm_patchram_plus binary, plus a systemd service to run it at boot time
	install -m 755 $SRC/packages/bsp/rk3399/brcm_patchram_plus_rk3399 $destination/usr/bin
	cp $SRC/packages/bsp/rk3399/rk3399-bluetooth.service $destination/lib/systemd/system/rk3588-bluetooth.service

	# Reuse the service file, ttyS0 -> ttyS6; BCM4345C5.hcd -> BCM4362A2.hcd
	sed -i 's/ttyS0/ttyS1/g' $destination/lib/systemd/system/rk3588-bluetooth.service
	sed -i 's/BCM4345C5.hcd/BCM4362A2.hcd/g' $destination/lib/systemd/system/rk3588-bluetooth.service
	return 0
}

function post_family_tweaks__JM10-3588_naming_audios() {
	display_alert "$BOARD" "Renaming JM10-3588 audios" "info"
	mkdir -p $SDCARD/etc/udev/rules.d/
	echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-hdmi0-sound", ENV{SOUND_DESCRIPTION}="HDMI0 Audio"' > $SDCARD/etc/udev/rules.d/90-naming-audios.rules
	return 0
}

function custom_kernel_config__JM10-3588_MV88E6XXX() {
	if [[ ${JM10_DSA_88E6390} = "yes" ]] && [[ ${BRANCH} = "vendor" || ${BRANCH} = "legacy" ]]; then
		display_alert "jm10-3588" "Only for Jm10 Hard Change Enabling MV88E6XXX HASH" "info"
		kernel_config_modifying_hashes+=(
			"CONFIG_NET_VENDOR_MARVELL=y"
			"CONFIG_NET_DSA=m"
			"CONFIG_NET_DSA_MV88E6XXX=m"
			"CONFIG_NET_DSA_MV88E6XXX_PTP=y"
			"CONFIG_MVMDIO=y"
		)

		if [[ -f .config ]] && [[ "${KERNEL_CONFIGURE:-yes}" != "yes" ]]; then
			display_alert "jm10-3588" "Only for Jm10 Hard Change Enabling dsa MV88E6XXX" "info"
			kernel_config_set_y CONFIG_NET_VENDOR_MARVELL
			kernel_config_set_m CONFIG_NET_DSA
			kernel_config_set_m CONFIG_NET_DSA_MV88E6XXX
			kernel_config_set_y CONFIG_NET_DSA_MV88E6XXX_PTP
			kernel_config_set_y CONFIG_MVMDIO
			run_kernel_make olddefconfig
		fi
	fi
}


function post_family_tweaks__JM10-3588_enable_services() {
	display_alert "fix armbian upgrade; hold kernel and dtb"
	if [[ ${BRANCH} = "legacy" ]] ; then
		display_alert "$BOARD" "Enabling JM10-3588 upgrade lock dtb adn kernel" "info"
		chroot_sdcard apt-mark hold linux-dtb-legacy-rk35xx
		chroot_sdcard apt-mark hold linux-u-boot-yjh-jm10-3588-legacy
	else
		display_alert "$BOARD" "Enabling JM10-3588 upgrade lock dtb adn kernel" "info"
		chroot_sdcard apt-mark hold linux-dtb-vendor-rk35xx
		chroot_sdcard apt-mark hold linux-u-boot-yjh-jm10-3588-vendor
	fi

	display_alert "$BOARD" "Enabling rk3588-bluetooth.service" "info"
	chroot_sdcard systemctl enable rk3588-bluetooth.service

	if [[ ${JM10_DSA_88E6390} = "yes" ]] && [[ ${BRANCH} = "vendor" || ${BRANCH} = "legacy" ]]; then
		#Only for Jm10 Hard Change. del /etc/netplan/10-dhcp-all-interfaces.yaml and add 10-dsa-MV88E6XXX-br0.yaml
		display_alert "$BOARD" "Only for Jm10 Hard Change del 10-dhcp-all-interfaces.yaml and add 10-dsa-MV88E6XXX-br0.yaml" "info"
		rm -rf ${SDCARD}/etc/netplan/*.yaml
		cat <<- EOF > "${SDCARD}/etc/netplan/10-dsa-MV88E6XXX-br0.yaml"
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      dhcp4: no
      dhcp6: no
    eth2:
      dhcp4: no
      dhcp6: no
    eth3:
      dhcp4: no
      dhcp6: no
    eth4:
      dhcp4: no
      dhcp6: no
    eth5:
      dhcp4: no
      dhcp6: no
    eth6:
      dhcp4: no
      dhcp6: no
    eth7:
      dhcp4: no
      dhcp6: no 
    eth8:
      dhcp4: no
      dhcp6: no
  bridges:
    br0:
      interfaces:
        - eth1
        - eth2
        - eth3
        - eth4
        - eth5
        - eth6
        - eth7
        - eth8
      dhcp4: yes
      dhcp6: yes
      #addresses:
      #  - 192.168.3.166/24
      #routes:
      #  - to: default
      #    via: 192.168.3.1
      #nameservers:
      #  addresses: [192.168.3.1, 8.8.8.8]
      parameters:
        stp: false
EOF
	fi
	chmod 600 "${SDCARD}/etc/netplan/10-dsa-MV88E6XXX-br0.yaml"
	return 0
}