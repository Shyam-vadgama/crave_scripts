#!/bin/bash

rm -rf .repo/local_manifests/

# Removing Old Trees
rm -rf device/xiaomi/warm
rm -rf device/xiaomi/warm-kernel
rm -rf vendor/xiaomi/warm
rm -rf hardware/qcom-caf/common
echo "Old Tree Removed"

# repo init rom
repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs --depth 1
echo "=================="
echo "Repo init success"
echo "=================="

# Build Sync
/opt/crave/resync.sh
echo "============="
echo "Sync success"
echo "============="

# Cloning Device Specific Trees 
echo "============================"
rm -rf device/xiaomi/warm device/xiaomi/warm-kernel vendor/xiaomi/warm hardware/xiaomi && git clone https://gitHub.com/Shyam-vadgama/device_xiaomi_warm device/xiaomi/warm && git clone https://gitHub.com/Shyam-vadgama/warm_kernel device/xiaomi/warm-kernel && git clone https://gitHub.com/Shyam-vadgama/vendor_xiaomi_warm vendor/xiaomi/warm  && git clone https://github.com/LineageOS/android_hardware_xiaomi hardware/xiaomi && mv device/xiaomi/warm-kernel/modules/system_dlkm/6.1.118-android14-11-ga3b9c44908dd-ab13320413/ device/xiaomi/warm-kernel/modules/system_dlkm/6.1.138-android14-11-g0c3d559bcd85-ab14529422
echo "Device Specific Trees clone success"
echo "============================"

# Cloning hardware/qcom-caf/common
git clone https://github.com/Shyam-vadgama/android_hardware_qcom-caf_common hardware/qcom-caf/common
echo "qcom common cloned success"

# Cloning Setting App's Forked Repo
# after repo sync of : bka tree
rm -rf packages/apps/Evolver
git clone -b bka https://github.com/Shyam-vadgama/packages_apps_Evolver.git packages/apps/Evolver
echo "Cloning Forked Evolver App Done"  

# Installing packages 
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev liblz4-tool libncurses6 libncurses-dev libsdl1.2-dev libssl-dev libwxgtk3.2-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev -y ;
sudo apt-get update && sudo apt-get install patchelf coreutils -y
echo "============="
echo "packages done"
echo "============="

# Export
export BUILD_USERNAME=Shyam-vadgama
export BUILD_HOSTNAME=crave
echo "======= Export Done ======"

rm -rf build/soong/fsgen;

# Set up build environment
. build/envsetup.sh

lunch lineage_warm-bp4a-userdebug 
echo "Lunch Success , Build Started "

m evolution
echo "Build Done"
echo "============="
