function post_install_kernel_debs__install_oecwxy4_lib() {
	use_clean_environment="yes" chroot_sdcard "wget http://debian.mirror.ac.za/debian/pool/main/o/openssl/libssl1.1_1.1.1n-0+deb10u3_arm64.deb -P /tmp"
	use_clean_environment="yes" chroot_sdcard "wget https://github.com/wxzmz/aic8800/releases/download/3.0%2Bgit20240116.ec460377-8/fw_printenv-tools.tgz -P /tmp"
	display_alert "Install oec-wxy4 libssl1.1" "info"
	use_clean_environment="yes" chroot_sdcard_apt_get_install "/tmp/libssl1.1_1.1.1n-0+deb10u3_arm64.deb "
	use_clean_environment="yes" chroot_sdcard "rm -f /tmp/libssl1.1_1.1.1n-0+deb10u3_arm64.deb"
	use_clean_environment="yes" chroot_sdcard "tar zxf /tmp/fw_printenv-tools.tgz -C /"
	use_clean_environment="yes" chroot_sdcard "rm -f /tmp/fw_printenv-tools.tgz"
}
