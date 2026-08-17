#!/bin/bash
set -e

echo "========================================"
echo " Cleaning old Repo manifest state"
echo "========================================"

# Keep downloaded source/cache.
# Remove only repo's manifest/client metadata.
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

# qcom_boards.mk
cat > hardware/qcom-caf/common/qcom_boards.mk <<'EOF'
# Board platforms lists to be used for
# TARGET_BOARD_PLATFORM specific featurization

# UM 3.18
QCOM_BOARD_PLATFORMS += msm8937
QCOM_BOARD_PLATFORMS += msm8953
QCOM_BOARD_PLATFORMS += msm8996

# UM 4.4
QCOM_BOARD_PLATFORMS += msm8998
QCOM_BOARD_PLATFORMS += sdm660

# UM 4.9
QCOM_BOARD_PLATFORMS += sdm710
QCOM_BOARD_PLATFORMS += sdm845

# UM 4.14
QCOM_BOARD_PLATFORMS += msmnile
QCOM_BOARD_PLATFORMS += sm6150
QCOM_BOARD_PLATFORMS += trinket
QCOM_BOARD_PLATFORMS += atoll

# UM 4.19
QCOM_BOARD_PLATFORMS += kona
QCOM_BOARD_PLATFORMS += lito
QCOM_BOARD_PLATFORMS += bengal

# UM 5.4
QCOM_BOARD_PLATFORMS += lahaina
QCOM_BOARD_PLATFORMS += holi

# UM 5.10
QCOM_BOARD_PLATFORMS += taro
QCOM_BOARD_PLATFORMS += parrot

# UM 5.15
QCOM_BOARD_PLATFORMS += kalama
QCOM_BOARD_PLATFORMS += crow

# UM 6.1
QCOM_BOARD_PLATFORMS += pineapple
QCOM_BOARD_PLATFORMS += volcano
QCOM_BOARD_PLATFORMS += pitti

# UM 6.6
QCOM_BOARD_PLATFORMS += sun
EOF 

cat > hardware/qcom-caf/common/qcom_defs.mk <<'EOF'
# Platform name variables - used in makefiles everywhere
MSMSTEPPE := sm6150
TRINKET := trinket #SM6125

# UM families
UM_3_18_FAMILY := msm8996 msm8937 msm8953
UM_4_4_FAMILY := msm8998 sdm660
UM_4_9_FAMILY := sdm845 sdm710
UM_4_14_FAMILY := msmnile $(MSMSTEPPE) $(TRINKET) atoll
UM_4_19_FAMILY := kona lito bengal
UM_5_4_FAMILY := lahaina holi
UM_5_10_FAMILY := taro parrot
UM_5_15_FAMILY := kalama crow
UM_6_1_FAMILY := pineapple volcano pitti
UM_6_6_FAMILY := sun

ifeq ($(TARGET_KERNEL_VERSION),6.6)
# UM 5.10 upgraded to UM 6.6
UM_6_6_FAMILY := $(UM_6_6_FAMILY) $(UM_5_10_FAMILY)
UM_5_10_FAMILY :=
endif
EOF

echo "========================================"
echo " Starting build"
echo "========================================"

. build/envsetup.sh

lunch lineage_warm-bp4a-userdebug

m evolution
