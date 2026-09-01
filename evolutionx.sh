#!/bin/bash

# Cloning Device Specific Trees
echo "============================"
echo "Cloning Device Trees..."
rm -rf device/xiaomi/warm device/xiaomi/warm-kernel vendor/xiaomi/warm hardware/xiaomi

git clone https://github.com/Shyam-vadgama/device_xiaomi_warm device/xiaomi/warm
git clone https://github.com/Shyam-vadgama/warm_kernel device/xiaomi/warm-kernel
git clone https://github.com/Shyam-vadgama/vendor_xiaomi_warm vendor/xiaomi/warm
git clone https://github.com/LineageOS/android_hardware_xiaomi hardware/xiaomi

mv device/xiaomi/warm-kernel/modules/system_dlkm/6.1.118-android14-11-ga3b9c44908dd-ab13320413/ device/xiaomi/warm-kernel/modules/system_dlkm/6.1.138-android14-11-g0c3d559bcd85-ab14529422

echo "Device Specific Trees cloned successfully."
echo "============================"

# Cloning hardware/qcom-caf/common
echo "Cloning qcom-caf common..."
rm -rf hardware/qcom-caf/common
git clone https://github.com/Shyam-vadgama/android_hardware_qcom-caf_common hardware/qcom-caf/common

echo "============================"
echo "Verifying qcom-caf/common files..."

# Check and display qcom_defs.mk
if [ -f "hardware/qcom-caf/common/qcom_defs.mk" ]; then
    echo "--- Content of qcom_defs.mk ---"
    cat hardware/qcom-caf/common/qcom_defs.mk
else
    echo "ERROR: hardware/qcom-caf/common/qcom_defs.mk not found!"
fi

echo ""

# Check and display qcom_boards.mk (or any matching file pattern)
if [ -f "hardware/qcom-caf/common/qcom_boards.mk" ]; then
    echo "--- Content of qcom_boards.mk ---"
    cat hardware/qcom-caf/common/qcom_boards.mk
else
    echo "ERROR: hardware/qcom-caf/common/qcom_boards.mk not found!"
fi

echo "============================"
