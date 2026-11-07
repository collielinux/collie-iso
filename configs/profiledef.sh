#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="collie"
iso_label="COLLIE_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Collie <https://omarchy.org>"
iso_application="Collie Installer"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
# build-iso.sh exports COLLIE_ARCH into the mkarchiso environment. aarch64
# firmware is UEFI-only, so the BIOS syslinux boot mode is dropped there.
arch="${COLLIE_ARCH:-x86_64}"
if [[ $arch == aarch64 ]]; then
  bootmodes=('uefi.grub')
else
  bootmodes=('bios.syslinux' 'uefi.grub')
fi
pacman_conf="pacman-offline.conf"
airootfs_image_type="squashfs"
# Package archives in the offline mirror are already zstd-compressed. Storing
# them in an outer stream saves little space but makes pacman decompress the
# outer layer while hashing and extracting every package during installation.
# (The root image stream is a plain file on the ISO, outside the squashfs.)
#
# Everything else in the live root is zstd rather than xz. Squashfs decompresses
# on the page-fault path through a single stream (CONFIG_SQUASHFS_DECOMP_SINGLE),
# where xz manages ~100MB/s against zstd's ~900MB/s, and the live root is read
# cold on every boot: kernel, plymouth, systemd, python, archinstall, gum. The
# whole ISO grows well under a percent for it, and with no x86 BCJ filter the
# same options build the aarch64 image too.
airootfs_image_tool_options=(
  '-comp' 'zstd'
  '-Xcompression-level' '19'
  '-b' '1M'
  '-action' 'uncompressed@subpathname(var/cache/collie/mirror/offline)'
)
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/root/configurator"]="0:0:755"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/collie-cidata-load"]="0:0:755"
  ["/usr/local/bin/collie-wait-root-image-verify"]="0:0:755"
  ["/usr/local/bin/collie-image-write"]="0:0:755"
  ["/usr/local/bin/collie-iso-cleanup-disk"]="0:0:755"
  ["/usr/local/bin/collie-release-install-target"]="0:0:755"
  ["/usr/local/bin/collie-install-dashboard"]="0:0:755"
  ["/usr/local/bin/collie-install-diagnose-media"]="0:0:755"
  ["/usr/local/bin/collie-luks-calibrate"]="0:0:755"
  ["/usr/local/bin/collie-iso-install"]="0:0:755"
  ["/usr/local/bin/collie-upload-log"]="0:0:755"
  ["/usr/local/sbin/collie-n1x-live-probe"]="0:0:755"
  ["/var/cache/collie/mirror/offline/"]="0:0:775"
)
