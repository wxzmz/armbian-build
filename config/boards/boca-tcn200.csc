# BOCA TCN200 MB-R50(CMCC) Rockchip RK3588s Octa core 4GB-32GB eMMC GBE TYPEC SATA USB2
BOARD_NAME="BOCA TCN200 RK3588"
BOARDFAMILY="rockchip-rk3588"
BOOT_SOC="rk3588"
BOARD_MAINTAINER="r-mt"
KERNEL_TARGET="legacy,vendor"
BOOTCONFIG="rk3588_defconfig"
BOOT_FDT_FILE="rockchip/rk3588s-boca-tcn200.dtb"
BOOT_LOGO="desktop"
FULL_DESKTOP="yes"
IMAGE_PARTITION_TABLE="gpt"
ENABLE_EXTENSIONS="mesa-vpu"
# SRC_EXTLINUX="yes"
# SRC_CMDLINE="rootwait earlycon=uart8250,mmio32,0xfeb50000 console=ttyFIQ0 irqchip.gicv3_pseudo_nmi=0 rootfstype=ext4"

function post_family_config__boca-tcn200_kernel() {
	display_alert "$BOARD" "mainline BOOTPATCHDIR" "info"	
	if [[ ${BRANCH} = "legacy" ]] ; then
		KERNELPATCHDIR="rockchip-5.10-boca-tcn200"
	else
		KERNELPATCHDIR="rockchip-6.1-boca-tcn200"
	fi	
}

function post_family_tweaks__boca-tcn200_enable_services() {
	display_alert "fix armbian upgrade; hold kernel and dtb"
	if [[ ${BRANCH} = "legacy" ]] ; then
		display_alert "$BOARD" "Enabling boca-tcn200 upgrade lock dtb adn kernel" "info"
		chroot_sdcard apt-mark hold linux-dtb-legacy-rk35xx
		#chroot_sdcard apt-mark hold linux-image-legacy-rk35xx
		chroot_sdcard apt-mark hold linux-u-boot-boca-tcn200-legacy
		chroot_sdcard ssh-keygen -A
	else
		display_alert "$BOARD" "Enabling boca-tcn200 upgrade lock dtb adn kernel" "info"
		chroot_sdcard apt-mark hold linux-dtb-vendor-rk35xx
		#chroot_sdcard apt-mark hold linux-image-vendor-rk35xx
		chroot_sdcard apt-mark hold linux-u-boot-boca-tcn200-vendor
	fi
	return 0
}

function pre_umount_final_image__fix_mpv() {
	display_alert "fix_mpv.conf"
	if [[ "${BUILD_DESKTOP}" == "yes" ]]; then
		cat <<- EOF > ${MOUNT}/etc/mpv/mpv.conf
			fs=yes
			hwdec=rkmpp
			vd-lavc-o=afbc=on
			vf=scale_rkrga=force_yuv=8bit
			slang=zh,chi,cht
			alang=en,chi,cht
			sid=auto
		EOF
	fi
}
