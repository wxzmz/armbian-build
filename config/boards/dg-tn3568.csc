# Rockchip RK3568 nas-lite 4GB RAM SoC  NVME eMMC USB2 USB3 SATA
BOARD_NAME="dg-tn3568"
BOARDFAMILY="rk35xx"
BOARD_MAINTAINER="R-mt"
BOOTCONFIG="rk3568-nas-lite_defconfig"
BOOT_SOC="rk3568"
KERNEL_TARGET="legacy,vendor"
BOOT_FDT_FILE="rockchip/rk3568-dg-tn3568.dtb"
IMAGE_PARTITION_TABLE="gpt"
BOOT_SCENARIO="spl-blobs"

DDR_BLOB="rk35/rk3568_ddr_1056MHz_v1.13.bin"
BL31_BLOB="rk35/rk3568_bl31_v1.33.elf"         # NOT a typo, bl31 is shared across 68 and 66

# Override family config for this board; let's avoid conditionals in family config.
function post_family_config__dg-tn3568_use_mainline_uboot() {
	display_alert "$BOARD" "mainline u-boot overrides" "info"

	BOOTSOURCE="https://github.com/orangepi-xunlong/u-boot-orangepi.git"
	BOOTBRANCH="commit:752ac3f2fdcfe9427ca8868d95025aacd48fc00b" # specific commit, from "branch:rk3568-2023.10"
	BOOTDIR="u-boot-${BOARD}"                                    # do not share u-boot directory
	BOOTPATCHDIR="v2017.09-rk3588-nas-lite"                           # fix npu-boot	
	BOOTDELAY=1 # Wait for UART interrupt to enter UMS/RockUSB mode etc
}

function post_family_config__nas-lite_kernel() {
	display_alert "$BOARD" "mainline BOOTPATCHDIR" "info"	
	if [[ ${BRANCH} = "legacy" ]] ; then
		KERNELPATCHDIR="rockchip-5.10-dg-tn3568"
	else
		KERNELPATCHDIR="rockchip-6.1-dg-tn3568"
	fi	
}

function custom_kernel_config__dg-tn3568_cpuinfo() {
	if [[ ${BRANCH} = "vendor" ]]; then
		display_alert "dg-tn3568" "vendor Enabling ROCKCHIP_CPUINFO HASH" "info"
		kernel_config_modifying_hashes+=(
			"CONFIG_NVMEM_RMEM=y"
			"CONFIG_NVMEM_ROCKCHIP_EFUSE=y"
			"CONFIG_NVMEM_ROCKCHIP_OTP=y"
			"CONFIG_ROCKCHIP_CPUINFO=y"
		)
		if [[ -f .config ]] && [[ "${KERNEL_CONFIGURE:-yes}" != "yes" ]]; then
			display_alert "dg-tn3568" "vendor Enabling ROCKCHIP_CPUINFO CONFIG" "info"
			kernel_config_set_y CONFIG_NVMEM_RMEM
			kernel_config_set_y CONFIG_NVMEM_ROCKCHIP_EFUSE
			kernel_config_set_y CONFIG_NVMEM_ROCKCHIP_OTP
			kernel_config_set_y CONFIG_ROCKCHIP_CPUINFO
			run_kernel_make olddefconfig
		fi
	fi
}

function post_family_tweaks__dg-tn3568_enable_services() {
	display_alert "fix armbian upgrade; hold kernel and dtb"
	if [[ ${BRANCH} = "legacy" ]] ; then
		display_alert "$BOARD" "Enabling dg-tn3568 upgrade lock dtb adn kernel" "info"
		chroot_sdcard apt-mark hold linux-dtb-legacy-rk35xx
		chroot_sdcard apt-mark hold linux-image-legacy-rk35xx
		chroot_sdcard apt-mark hold linux-u-boot-dg-tn3568-legacy
		chroot_sdcard ssh-keygen -A
	else
		display_alert "$BOARD" "Enabling dg-tn3568 upgrade lock dtb adn kernel" "info"
		chroot_sdcard apt-mark hold linux-dtb-vendor-rk35xx
		chroot_sdcard apt-mark hold linux-image-vendor-rk35xx
		chroot_sdcard apt-mark hold linux-u-boot-dg-tn3568-vendor
	fi
	return 0
}


function pre_umount_final_image__fix_extlinux() {
	display_alert "fix_legacy_ssh"
	# if [[ ${BRANCH} = "legacy" ]] ; then
		# cp -f $SRC/packages/bsp/rockchip/sshd_config $destination/etc/ssh/sshd_config
	# fi
	display_alert "fix_extlinux"
	cd ${MOUNT}/boot/
	ln -sf ./dtb/rockchip/rk3568-dg-tn3568.dtb rk-kernel.dtb # fix npu-boot		 
	cd $SRC	
}