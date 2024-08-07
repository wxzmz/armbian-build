# Rockchip RK3566 quad core 8GB RAM SoC WIFI/BT eMMC USB2/3 SATA
BOARD_NAME="dr4-rk3566"
BOARDFAMILY="rk35xx"
BOARD_MAINTAINER=""
BOOTCONFIG="dr4-rk3566_defconfig"
BOOT_SOC="rk3566"
KERNEL_TARGET="legacy"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3566-dr4.dtb"
IMAGE_PARTITION_TABLE="gpt"
#BOOTFS_TYPE="fat"
BOOT_SCENARIO="spl-blobs"
#enable_extension "mesa-vpu"

# Newer blobs. Tested to work with opi3b
DDR_BLOB="rk35/rk3566_ddr_1056MHz_v1.13.bin"
BL31_BLOB="rk35/rk3568_bl31_v1.33.elf"         # NOT a typo, bl31 is shared across 68 and 66
ROCKUSB_BLOB="rk35/rk3566_spl_loader_1.14.bin" # For `EXT=rkdevflash` flashing

# Override family config for this board; let's avoid conditionals in family config.
function post_family_config__dr4-rk3566_uboot() {
	display_alert "$BOARD" "mainline u-boot overrides" "info"

	BOOTSOURCE="https://github.com/orangepi-xunlong/u-boot-orangepi.git"
	BOOTBRANCH="commit:752ac3f2fdcfe9427ca8868d95025aacd48fc00b" # specific commit, from "branch:rk3568-2023.10"
	BOOTDIR="u-boot-${BOARD}"                                    # do not share u-boot directory
	BOOTPATCHDIR="v2017.09-rk3588-dr4"

	BOOTDELAY=1 # Wait for UART interrupt to enter UMS/RockUSB mode etc
}

function post_family_config__dr4-rk3566_kernel() {
	display_alert "$BOARD" "mainline BOOTPATCHDIR" "info"
	if [[ ${BRANCH} = "legacy" ]]; then
		KERNELPATCHDIR="rockchip-5.10-dr4"	
	elif [[ ${BRANCH} = "vendor" ]]; then
		KERNELPATCHDIR="rockchip-6.1-dr4"
		#CRUSTCONFIG="rockchip-6.1.config"	
	fi
}