#!/bin/bash
set -e

echo "========================================"
echo " Cleaning old Repo manifest state"
echo "========================================"

# Keep downloaded source/cache.
# Remove only repo's manifest/client metadata.
rm -rf .repo/manifests
rm -rf .repo/manifests.git

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
rm -rf hardware/qcom-caf/common

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

cd vendor/xiaomi/warm
git checkout c0417ffc868d6f96f8e2ee6252eabbcebfa91927
cd -

echo "========================================"
echo " Cloning Qualcomm CAF common"
echo "========================================"

git clone https://github.com/Shyam-vadgama/android_hardware_qcom-caf_common \
    -b lineage-23.2 hardware/qcom-caf/common

echo "========================================"
echo " Starting build"
echo "========================================"

. build/envsetup.sh

lunch lineage_warm-ap4a-userdebug || \
lunch lineage_warm-bp4a-userdebug

m evolution
