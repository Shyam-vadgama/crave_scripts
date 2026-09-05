echo "============================"
echo "Cleaning and Re-initializing Manifest..."
echo "============================"

# 1. Clean local manifests & init repo
rm -rf .repo/local_manifests/

repo init \
    -u https://github.com/RisingOS-Revived/android \
    -b sixteen-qpr \
    --git-lfs \
    --depth 1

# 2. Crave Resync
/opt/crave/resync.sh

echo "============================"
echo "Cloning Device Trees..."
echo "============================"

rm -rf \
    device/xiaomi/warm \
    device/xiaomi/warm-kernel \
    vendor/xiaomi/warm \
    hardware/xiaomi

# Device tree
git clone \
    https://github.com/Shyam-vadgama/device_xiaomi_warm.git \
    --depth 1 \
    device/xiaomi/warm

# Kernel
git clone \
    https://github.com/Shyam-vadgama/warm_kernel \
    device/xiaomi/warm-kernel

# Vendor
git clone \
    https://github.com/Shyam-vadgama/vendor_xiaomi_warm \
    vendor/xiaomi/warm

# Xiaomi hardware
git clone \
    https://github.com/LineageOS/android_hardware_xiaomi \
    hardware/xiaomi

echo "============================"
echo "Updating lineage_warm.mk..."
echo "============================"

DEVICE_MK="device/xiaomi/warm/lineage_warm.mk"



echo "============================"
echo "Renaming Kernel Module Directory..."
echo "============================"

OLD_MODULE_DIR="device/xiaomi/warm-kernel/modules/system_dlkm/6.1.118-android14-11-ga3b9c44908dd-ab13320413"
NEW_MODULE_DIR="device/xiaomi/warm-kernel/modules/system_dlkm/6.1.138-android14-11-g0c3d559bcd85-ab14529422"

if [ -d "$OLD_MODULE_DIR" ]; then

    if [ -e "$NEW_MODULE_DIR" ]; then
        echo "Warning: Destination module directory already exists:"
        echo "$NEW_MODULE_DIR"
        echo "Skipping rename."
    else
        mv "$OLD_MODULE_DIR" "$NEW_MODULE_DIR"
        echo "Kernel modules renamed successfully."
    fi

else
    echo "Warning: Source module directory not found:"
    echo "$OLD_MODULE_DIR"
    echo "Skipping module rename."
fi

echo "============================"
echo "Cloning qcom-caf common..."
echo "============================"

rm -rf hardware/qcom-caf/common

git clone \
    https://github.com/Shyam-vadgama/android_hardware_qcom-caf_common \
    hardware/qcom-caf/common

echo "============================"
echo "Verifying qcom-caf/common files..."
echo "============================"

if [ -f hardware/qcom-caf/common/qcom_defs.mk ]; then
    echo "--- Content of qcom_defs.mk ---"
    cat hardware/qcom-caf/common/qcom_defs.mk
else
    echo "ERROR: hardware/qcom-caf/common/qcom_defs.mk not found!"
    exit 1
fi

echo

if [ -f hardware/qcom-caf/common/qcom_boards.mk ]; then
    echo "--- Content of qcom_boards.mk ---"
    cat hardware/qcom-caf/common/qcom_boards.mk
else
    echo "ERROR: hardware/qcom-caf/common/qcom_boards.mk not found!"
    exit 1
fi

echo "============================"
echo "Setup Environment & Build"
echo "============================"

source build/envsetup.sh

lunch lineage_warm-bp4a-userdebug

echo "Lunch Done, Now Building..."
echo "============================"

gk -s 

mka bacon

echo "============================"
echo "Build Done Successfully!"
echo "============================"
