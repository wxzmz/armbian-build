# Rockchip RK3568 nas-lite 4GB RAM SoC  NVME eMMC USB2 USB3 SATA
BOARD_NAME="nas-lite"
BOARDFAMILY="rk35xx"
BOARD_MAINTAINER=""
BOOTCONFIG="rk3568-nas-lite_defconfig"
BOOT_SOC="rk3568"
KERNEL_TARGET="legacy,vendor"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3568-nas-lite.dtb"
IMAGE_PARTITION_TABLE="gpt"
BOOT_SCENARIO="spl-blobs"
#ENABLE_EXTENSIONS="mesa-vpu"

DDR_BLOB="rk35/rk3568_ddr_1056MHz_v1.13.bin"
BL31_BLOB="rk35/rk3568_bl31_v1.33.elf"         # NOT a typo, bl31 is shared across 68 and 66
#ROCKUSB_BLOB="rk35/rk3566_spl_loader_1.14.bin" # For `EXT=rkdevflash` flashing

# Override family config for this board; let's avoid conditionals in family config.
function post_family_config__nas-lite_use_mainline_uboot() {
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
		KERNELPATCHDIR="rockchip-5.10-nas-lite"
	else
		KERNELPATCHDIR="rockchip-6.1-nas-lite"
	fi	
}

function custom_kernel_config__nas-lite_pcie() {
	if [[ ${BRANCH} = "legacy" ]]; then
		display_alert "dg-tn3568" "vendor Enabling ROCKCHIP_CPUINFO HASH" "info"
		kernel_config_modifying_hashes+=(
			"# CONFIG_PCIEASPM_DEFAULT is not set"
			"CONFIG_PCIEASPM_POWER_SUPERSAVE=y"
		)
		if [[ -f .config ]] && [[ "${KERNEL_CONFIGURE:-yes}" != "yes" ]]; then
			display_alert "dg-tn3568" "vendor Enabling ROCKCHIP_CPUINFO CONFIG" "info"
			kernel_config_set_n CONFIG_PCIEASPM_DEFAULT
			kernel_config_set_y CONFIG_PCIEASPM_POWER_SUPERSAVE
			run_kernel_make olddefconfig
		fi
	fi

	if [[ ${BRANCH} = "vendor" ]]; then
		display_alert "dg-tn3568" "vendor Enabling ROCKCHIP_CPUINFO HASH" "info"
		kernel_config_modifying_hashes+=(
			"# CONFIG_PCIEASPM_DEFAULT is not set"
			"CONFIG_PCIEASPM_POWER_SUPERSAVE=y"
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
			kernel_config_set_n CONFIG_PCIEASPM_DEFAULT
			kernel_config_set_y CONFIG_PCIEASPM_POWER_SUPERSAVE
			run_kernel_make olddefconfig
		fi
	fi
}


function post_family_tweaks__nas-lite() {
    display_alert "$BOARD" "Installing board tweaks" "info"
	cp -R $SRC/packages/blobs/rtl8723bt_fw/* $SDCARD/lib/firmware/rtl_bt/
	cp -R $SRC/packages/blobs/station/firmware/* $SDCARD/lib/firmware/
	if [[ ${BRANCH} = "legacy" ]] ; then
		display_alert "$BOARD" "Enabling nas-lite upgrade lock dtb adn kernel" "info"
		chroot_sdcard apt-mark hold linux-dtb-legacy-rk35xx
		chroot_sdcard apt-mark hold linux-image-legacy-rk35xx
		chroot_sdcard apt-mark hold linux-u-boot-nas-lite-legacy
		chroot_sdcard ssh-keygen -A
	else
		display_alert "$BOARD" "Enabling nas-lite upgrade lock dtb adn kernel" "info"
		chroot_sdcard apt-mark hold linux-dtb-vendor-rk35xx
		chroot_sdcard apt-mark hold linux-image-vendor-rk35xx
		chroot_sdcard apt-mark hold linux-u-boot-nas-lite-vendor
	fi

	return 0
}

function pre_umount_final_image__fix_extlinux() {
		display_alert "fix_extlinux"
		cd ${MOUNT}/boot/
		ln -sf ./dtb/rockchip/rk3568-nas-lite.dtb rk-kernel.dtb # fix npu-boot
		cd $SRC	
}