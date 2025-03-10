#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

DEVICE=vermeer
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

export TARGET_ENABLE_CHECKELF=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

function vendor_imports() {
    cat <<EOF >>"$1"
		"device/xiaomi/vermeer",
		"hardware/qcom-caf/wlan",
		"hardware/qcom-caf/sm8550",
		"hardware/xiaomi",
		"vendor/qcom/opensource/commonsys-intf/display",
		"vendor/qcom/opensource/dataservices",
EOF
}

function lib_to_package_fixup_vendor_variants() {
    if [ "$2" != "vendor" ]; then
        return 1
    fi

    case "$1" in
        vendor.qti.hardware.camera.device@1.0.so | \
        vendor.qti.hardware.camera.postproc@1.0.so | \
        vendor.qti.imsrtpservice@3.0 | \
        vendor.qti.imsrtpservice@3.1 | \
        vendor.qti.diaghal@1.0)
            echo "$1-vendor"
            ;;
        audio.primary.kalama | \
        libagmclient | \
        libpalclient | \
        libwpa_client) ;;
        *)
            return 1
            ;;
    esac
}

function lib_to_package_fixup_odm_variants() {
    if [ "$2" != "odm" ]; then
        return 1
    fi

    case "$1" in
        audio.primary.kalama | \
        libagmmixer) ;;
        *)
            return 1
            ;;
    esac
}

function lib_to_package_fixup() {
    lib_to_package_fixup_clang_rt_ubsan_standalone "$1" ||
        lib_to_package_fixup_proto_3_9_1 "$1" ||
        lib_to_package_fixup_vendor_variants "$@" ||
        lib_to_package_fixup_odm_variants "$@"
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}"

# Warning headers and guards
write_headers

write_makefiles "${MY_DIR}/proprietary-files.txt" true

# Finish
write_footers
