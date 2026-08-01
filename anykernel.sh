### AnyKernel3 Ramdisk Mod Script
## KernelSU / SukiSU-Ultra / ResukiSU with SuSFS
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

# =============
# BBG efisp / abl partition whitelist control
# =============
ui_print "-----------------"
ui_print " "
ui_print "Are you using the efisp exploit and need to"
ui_print "whitelist the abl and efisp partitions?"
ui_print "-----------------"
ui_print " "
ui_print "Volume Up: No, keep full BBG security (default)"
ui_print "Volume Down: Yes, whitelist abl and efisp"
ui_print "-----------------"

handle_input
key_click="$KEY_RESULT"

case "$key_click" in
    "KEY_VOLUMEDOWN")
        ui_print "Patching cmdline to allow abl and efisp flashing!"
        patch_cmdline "oplusboot.secure_user_mode" "oplusboot.secure_user_mode=0"
        ;;
    "KEY_VOLUMEUP")
        ui_print "Flashing the kernel as is with full BBG security!"
        patch_cmdline "oplusboot.secure_user_mode" ""
        ;;
    *)
        ui_print "No/Unknown input, keeping full BBG security"
        patch_cmdline "oplusboot.secure_user_mode" ""
        ;;
esac

if [ -f "split_img/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
fi
