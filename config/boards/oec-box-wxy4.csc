# Rockchip RK3566 oec-box-wxy4 2GB RAM SoC  eMMC USB2 USB3 SATA
BOARD_NAME="oec-box-wxy4"
BOARDFAMILY="rk35xx"
BOARD_MAINTAINER=""
BOOTCONFIG="rk3566-oec-box-wxy4_defconfig"
BOOT_SOC="rk3566"
KERNEL_TARGET="legacy,vendor,edge"
BOOT_FDT_FILE="rockchip/rk3566-oec-box-wxy4.dtb"
IMAGE_PARTITION_TABLE="gpt"
BOOT_SCENARIO="spl-blobs"
ENABLE_EXTENSIONS="oec-wxy4-lib"
#FIXED_IMAGE_SIZE=4096

SRC_EXTLINUX="yes"
SRC_CMDLINE="rootwait rootfstype=ext4 console=ttyFIQ0 console=tty1 loglevel=7 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 earlycon=uart8250,mmio32,0xfe660000"
#6.8.9
#SRC_CMDLINE="rootwait rootfstype=ext4 console=ttyFIQ0 console=tty1 loglevel=7 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 "
# Newer blobs. Tested to work with opi3b
DDR_BLOB="rk35/rk3566_ddr_1056MHz_v1.13.bin"
BL31_BLOB="rk35/rk3568_bl31_v1.33.elf"         # NOT a typo, bl31 is shared across 68 and 66
ROCKUSB_BLOB="rk35/rk3566_spl_loader_1.14.bin" # For `EXT=rkdevflash` flashing

# Override family config for this board; let's avoid conditionals in family config.
function post_family_config__oec-box-wxy4_use_mainline_uboot() {
	display_alert "$BOARD" "mainline u-boot overrides" "info"

	BOOTSOURCE="https://github.com/orangepi-xunlong/u-boot-orangepi.git"
	BOOTBRANCH="commit:752ac3f2fdcfe9427ca8868d95025aacd48fc00b" # specific commit, from "branch:rk3568-2023.10"
	BOOTDIR="u-boot-${BOARD}"                                    # do not share u-boot directory
	BOOTPATCHDIR="v2017.09-rk3588"                           # empty, patches are already in Kwiboo's branch:rk3568-2023.10	
	BOOTDELAY=1 # Wait for UART interrupt to enter UMS/RockUSB mode etc
#	KERNELPATCHDIR="rockchip-5.10-wxy4"
}

function post_family_config__oec-box-wxy4_kernel() {
	display_alert "$BOARD" "mainline BOOTPATCHDIR" "info"
	if [[ ${BRANCH} = "legacy" ]] ; then
		KERNELPATCHDIR="rockchip-5.10-wxy4"
	else
		KERNELPATCHDIR="rockchip-6.1-wxy4"
	fi	

}


function pre_umount_final_image__fix_extlinux() {

	if [[ $SRC_EXTLINUX == yes ]]; then
		display_alert "fix_extlinux"
		cd ${MOUNT}/boot/
		initrd_file="$(find ./ -name initrd.img-*)"
		initrd_file_name="$(basename "$initrd_file")"
		ln -sf $initrd_file_name uInitrd
		cd $SRC	
	fi	
}

