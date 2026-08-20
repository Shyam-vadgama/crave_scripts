#!/bin/bash
set -e

echo "========================================"
echo " Cleaning old Repo manifest state"
echo "========================================"

rm -rf .repo/local_manifest

echo "========================================"
echo " Initializing Infinity-X manifest"
echo "========================================"

repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault

echo "========================================"
echo " Syncing source"
echo "========================================"

/opt/crave/resync.sh

echo "========================================"
echo " Cleaning device-specific trees"
echo "========================================"

rm -rf device/xiaomi/warm
rm -rf vendor/xiaomi/warm
rm -rf device/xiaomi/warm-kernel
rm -rf hardware/xiaomi

echo "========================================"
echo " Cloning device tree"
echo "========================================"

git clone https://github.com/Shyam-vadgama/device_xiaomi_warm \
    device/xiaomi/warm

echo "========================================"
echo " Cloning kernel"
echo "========================================"

git clone https://github.com/Shyam-vadgama/warm-kernel \
    -b main device/xiaomi/warm_kernel

echo "========================================"
echo " Renaming kernel modules directory"
echo "========================================"

OLD_KVER="6.1.118-android14-11-ga3b9c44908dd-ab13320413"
NEW_KVER="6.1.138-android14-11-g0c3d559bcd85-ab14529422"
MODULES_BASE="device/xiaomi/warm_kernel/modules/system_dlkm"

if [ -d "$MODULES_BASE/$OLD_KVER" ]; then
    mv "$MODULES_BASE/$OLD_KVER" "$MODULES_BASE/$NEW_KVER"
    echo "Renamed: $OLD_KVER -> $NEW_KVER"
elif [ -d "$MODULES_BASE/$NEW_KVER" ]; then
    echo "Skip: $NEW_KVER already exists"
else
    echo "WARNING: Neither old nor new kernel version dir found in $MODULES_BASE"
    ls "$MODULES_BASE/" 2>/dev/null || echo "Directory $MODULES_BASE does not exist"
fi

echo "========================================"
echo " Cloning Xiaomi hardware"
echo "========================================"

git clone https://github.com/LineageOS/android_hardware_xiaomi \
    -b lineage-23.2 hardware/xiaomi

echo "========================================"
echo " Cloning vendor"
echo "========================================"

git clone https://github.com/Shyam-vadgama/vendor_xiaomi_warm.git \
    -b lineage-23.2 vendor/xiaomi/warm

echo "========================================"
echo " Patching Qualcomm CAF common"
echo "========================================"

BOARDS_MK="hardware/qcom-caf/common/qcom_boards.mk"
DEFS_MK="hardware/qcom-caf/common/qcom_defs.mk"

# Fresh fetch — pichle builds ki corrupt state clean karo
curl -fsSL \
    "https://raw.githubusercontent.com/LineageOS/android_hardware_qcom-caf_common/lineage-22.2/qcom_boards.mk" \
    -o "$BOARDS_MK"

curl -fsSL \
    "https://raw.githubusercontent.com/LineageOS/android_hardware_qcom-caf_common/lineage-22.2/qcom_defs.mk" \
    -o "$DEFS_MK"

# Fresh file pe pitti add karo
sed -i '/^QCOM_BOARD_PLATFORMS += volcano/a QCOM_BOARD_PLATFORMS += pitti' "$BOARDS_MK"
sed -i '/^UM_6_1_FAMILY :=/ s/$/ pitti/' "$DEFS_MK"

echo "=== Patch Verification ==="
grep -n 'pineapple\|volcano\|pitti' "$BOARDS_MK"
grep -n 'UM_6_1_FAMILY' "$DEFS_MK"
echo "=========================="

echo "========================================"
echo " Updating maintainer in lineage_warm.mk"
echo "========================================"

LINEAGE_MK="device/xiaomi/warm/lineage_warm.mk"

# Remove existing maintainer line if present
sed -i '/^[[:space:]]*INFINITY_MAINTAINER[[:space:]]*:=/d' "$LINEAGE_MK"

# Add maintainer as the last line
echo 'INFINITY_MAINTAINER := "Shyam-Vadgama"' >> "$LINEAGE_MK"

echo "Added:"
tail -n 1 "$LINEAGE_MK"



echo "========================================"
echo " Starting build"
echo "========================================"

. build/envsetup.sh
lunch lineage_warm-userdebug
m installclean

m bacon -j$(nproc --all)
