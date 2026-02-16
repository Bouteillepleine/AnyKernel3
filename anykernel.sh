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
do.cleanuponabort=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
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

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

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

# =============
# SUSFS Module Installation
# =============
if [ -f "$AKHOME/ksu_module_susfs_1.5.2+_Release.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+_Release.zip"
    ui_print "  -> Found SUSFS Module (Release)"
elif [ -f "$AKHOME/ksu_module_susfs_1.5.2+_CI.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+_CI.zip"
    ui_print "  -> Found SUSFS Module (CI)"
else
    MODULE_PATH=""
    ui_print "No SUSFS Module Found, You May Have Selected None Mode,Skipping Installation"
fi

if [ -n "$MODULE_PATH" ]; then
    KSUD_PATH="/data/adb/ksud"
    ui_print "-----------------"
    ui_print " "
    ui_print "Install SUSFS Module?"
    ui_print "-----------------"
    ui_print " "
    ui_print " "
    ui_print "Volume Up: Skip Installation"
    ui_print "Volume Down: Install Module"
    ui_print "-----------------"

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            if [ -f "$KSUD_PATH" ]; then
                ui_print " "
                ui_print "Installing SUSFS Module..."
                /data/adb/ksud module install "$MODULE_PATH"
                ui_print " "
                ui_print "Installation Complete!"
            else
                ui_print " "
                ui_print "KSUD Not Found, Skipping Installation"
            fi
            ;;
        "KEY_VOLUMEUP")
            ui_print "The SUSFS Module Installation has been Skipped"
            ui_print " Skipped SUSFS Module Installation"
            ;;
        *)
            ui_print "Unknown KeyInput; SUSFS Module Installation has been Skipped"
            ui_print " Unknown Key Input. Skipped SUSFS Module Installation"
            ;;
    esac
fi
