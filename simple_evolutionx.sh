#!/bin/bash
set -e

echo "========================================"
echo " Cleaning old Repo manifest state"
echo "========================================"

rm -rf .repo/local_manifest

echo "========================================"
echo " Initializing Evolution-X manifest"
echo "========================================"

repo init \
    -u https://github.com/Evolution-X/manifest \
    -b bka \
    --git-lfs \
    --depth=1

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
    -b evo device/xiaomi/warm

echo "========================================"
echo " Cloning kernel"
echo "========================================"

git clone https://github.com/Shyam-vadgama/warm-kernel \
    -b main device/xiaomi/warm-kernel

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
echo " Starting build"
echo "========================================"

. build/envsetup.sh

lunch lineage_warm-bp4a-userdebug

m evolution
