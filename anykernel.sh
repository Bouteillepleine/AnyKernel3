### AnyKernel3 Ramdisk Mod Script
## KernelSU / SukiSU-Ultra / ResukiSU with NMS
## OSMOSIS @ XDA-Developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=OnePlus Kernels Powered By ⚡Ultra⚡
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.check_boot_version=0
do.cleanuponabort=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
keycheck.timeout=25
'; } # end properties

### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    4.1*) ksu_supported=true ;;
    5.1*) ksu_supported=true ;;
    6.12*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print "KSU Supported: $ksu_supported"
$ksu_supported || abort "Non-GKI Device, Abort"

# =============
# Root detection method (Magisk detection)
# =============
if [ -d /data/adb/magisk ] || [ -f /sbin/.magisk ]; then
    ui_print "-----------------"
    ui_print " "
    ui_print "Magisk Has Been Detected (Residual Files)"
    ui_print "Flashing the Kernel May Brick Your Device"
    ui_print "Do You Want To Continue?"
    ui_print "-----------------"
    ui_print " "
    ui_print " "
    ui_print "Volume Up: Exit script (Recommended)"
    ui_print "Volume Down: Continue Installation (At Your Own Risk)"
    ui_print "============="

    handle_input
    key_click="$KEY_RESULT"

    case "$key_click" in
        "KEY_VOLUMEUP")
            ui_print "You Have Selected To Exit The Script, The Installation Has Been Safely Terminated"
            ui_print " You Chose To Exit, Installation Aborted Safely"
            exit 0
            ;;
        "KEY_VOLUMEDOWN")
            ui_print "You Have Chosen To Continue The Installation. Please Be Aware Of The Risks"
            ui_print " You Chose To Continue Installation, Proceed With Caution"
            ;;
        *)
            ui_print "Unknown Key Input, Script Has Exited"
            ui_print " Unknown Key Input, Exiting Script"
            exit 1
            ;;
    esac
fi

ui_print "Start Installing The Kernel..."
ui_print "Powered By ⚡Ultra⚡"

split_boot

if [ -f "split_img/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
fi

# The susfs module built against THIS kernel travels inside this zip, so it can never be
# paired with a kernel it was not compiled for. AK3 unpacks to a tmpfs that do.cleanup=1
# removes, so hand it to storage on the way past.
#
# Best-effort by design. In recovery without decryption /data/media/0 is unreadable and
# every target below fails; the kernel must still flash, so nothing here is allowed to
# matter. update-binary runs without `set -e`, so a failing test or cp cannot abort it.
# When this does fail, the zip itself is still on the device and the loader reads the
# module straight out of it.
if [ -f "$AKHOME/susfs_guard_lkm.ko" ]; then
  susfs_placed=
  for susfs_dir in /sdcard/Download /storage/emulated/0/Download /data/local/tmp; do
    if [ -d "$susfs_dir" ] && cp -f "$AKHOME/susfs_guard_lkm.ko" "$susfs_dir/" 2>/dev/null; then
      susfs_placed=$susfs_dir
      break
    fi
  done
  if [ -n "$susfs_placed" ]; then
    ui_print " " "susfs module placed in $susfs_placed"
  else
    ui_print " " "susfs module left in the zip (/data not writable here)"
  fi
fi
