#!/bin/bash
set -e

# Local manifests setup
mkdir -p .repo/local_manifests
cat > .repo/local_manifests/remove.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remove-project name="packages/modules/UprobeStats" />
</manifest>
EOF

# Repo init
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --depth=1

# Build Sync
/opt/crave/resync.sh

rm -rf device/xiaomi/warm
rm -rf vendor/xiaomi/warm
rm -rf device/xiaomi/warm-kernel
rm -rf hardware/xiaomi
rm -rf hardware/qcom-caf/common

# Device tree
git clone https://github.com/Shyam-vadgama/device_xiaomi_warm -b lineage-23.2 device/xiaomi/warm

# Kernel
git clone https://github.com/Shyam-vadgama/warm-kernel -b main device/xiaomi/warm-kernel

# Hardware
git clone https://github.com/LineageOS/android_hardware_xiaomi -b lineage-23.2 hardware/xiaomi

# Vendor tree
git clone https://github.com/Shyam-vadgama/vendor_xiaomi_warm.git -b lineage-23.2 vendor/xiaomi/warm
cd vendor/xiaomi/warm && git checkout c0417ffc868d6f96f8e2ee6252eabbcebfa91927 && cd -

git clone https://github.com/Shyam-vadgama/android_hardware_qcom-caf_common -b lineage-23.2 hardware/qcom-caf/common

. build/envsetup.sh
lunch lineage_warm-ap4a-userdebug
mka bacon
