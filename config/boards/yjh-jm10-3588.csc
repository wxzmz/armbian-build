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
IMAGE_PARTITION_TABLE="gpt"
ENABLE_EXTENSIONS="mesa-vpu"

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
	display_alert "$BOARD" "Renaming firefly-JM10-3588 audios" "info"
	mkdir -p $SDCARD/etc/udev/rules.d/
	echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-hdmi0-sound", ENV{SOUND_DESCRIPTION}="HDMI0 Audio"' > $SDCARD/etc/udev/rules.d/90-naming-audios.rules
	return 0
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
	chroot_sdcard_apt_get_install rfkill
	chroot_sdcard systemctl enable rk3588-bluetooth.service
	return 0
}