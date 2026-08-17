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

# qcom_boards.mk — pitti add karo (idempotent)
grep -q 'QCOM_BOARD_PLATFORMS += pitti' hardware/qcom-caf/common/qcom_boards.mk || \
    sed -i '/QCOM_BOARD_PLATFORMS += volcano/a QCOM_BOARD_PLATFORMS += pitti' \
        hardware/qcom-caf/common/qcom_boards.mk

# qcom_defs.mk — UM_6_1_FAMILY mein pitti add karo (idempotent)
grep -q 'pitti' hardware/qcom-caf/common/qcom_defs.mk || \
    sed -i 's/UM_6_1_FAMILY := pineapple volcano/UM_6_1_FAMILY := pineapple volcano pitti/' \
        hardware/qcom-caf/common/qcom_defs.mk

echo "========================================"
echo " Starting build"
echo "========================================"

. build/envsetup.sh

lunch lineage_warm-bp4a-userdebug

m evolution
