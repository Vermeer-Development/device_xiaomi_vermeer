#
# Copyright (C) 2022 Paranoid Android
#
# SPDX-License-Identifier: Apache-2.0
#

TARGET_USES_KERNEL_PLATFORM ?= true
KERNEL_PRODUCT_DIR := kernel_obj
KERNEL_MODULES_INSTALL := dlkm
KERNEL_PREBUILT_DIR := device/xiaomi/vermeer-kernel
KERNEL_MODULES_OUT ?= $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/$(KERNEL_MODULES_INSTALL)/lib/modules

ifeq ($(TARGET_USES_KERNEL_PLATFORM),true)

ifeq ($(wildcard $(KERNEL_PREBUILT_DIR)/),)
$(warning $(KERNEL_PREBUILT_DIR) does not exist, have you compiled kernel?)
endif

# Path to system_dlkm artifacts directory
ifneq ($(wildcard $(KERNEL_PREBUILT_DIR)/system_dlkm/),)
BOARD_SYSTEM_DLKM_SRC := $(KERNEL_PREBUILT_DIR)/system_dlkm
ifeq ($(wildcard $(BOARD_SYSTEM_DLKM_SRC)/lib/modules/),)
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(BOARD_SYSTEM_DLKM_SRC)/,$(TARGET_COPY_OUT_SYSTEM_DLKM)/lib/modules)
endif
endif

# DLKM
define get-kernel-modules
$(if $(wildcard $(KERNEL_PREBUILT_DIR)/$(1)/$(2)), \
	$(addprefix $(KERNEL_PREBUILT_DIR)/$(1)/,$(notdir $(file < $(KERNEL_PREBUILT_DIR)/$(1)/$(2)))), \
	$(wildcard $(KERNEL_PREBUILT_DIR)/$(1)/*.ko))
endef
prepend-kernel-modules = $(eval $1 := $2 $(filter-out $2,$($1)))
ifneq ($(wildcard $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/),)

first_stage_modules := $(call get-kernel-modules,vendor_ramdisk,modules.load)
recovery_modules := $(call get-kernel-modules,vendor_ramdisk,modules.load.recovery)

else
first_stage_modules := $(call get-kernel-modules,.,modules.load)
recovery_modules := $(call get-kernel-modules,.,modules.load.recovery)
endif

gki_modules := $(call get-kernel-modules,system_dlkm,modules.load)
second_stage_modules := $(call get-kernel-modules,vendor_dlkm,modules.load)

$(call prepend-kernel-modules,BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD,$(first_stage_modules))
$(call prepend-kernel-modules,BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD,$(recovery_modules))
$(call prepend-kernel-modules,BOARD_GKI_KERNEL_MODULES,$(gki_modules))
$(call prepend-kernel-modules,BOARD_VENDOR_KERNEL_MODULES,$(second_stage_modules))

BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(wildcard $(KERNEL_PREBUILT_DIR)/vendor_dlkm/modules.blocklist)
BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(wildcard $(KERNEL_PREBUILT_DIR)/vendor_dlkm/modules.blocklist)

ifneq ("$(wildcard $(KERNEL_PREBUILT_DIR)/vendor_dlkm/system_dlkm.modules.blocklist)", "")
PRODUCT_COPY_FILES += $(KERNEL_PREBUILT_DIR)/vendor_dlkm/system_dlkm.modules.blocklist:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/system_dlkm.modules.blocklist
endif

BOARD_VENDOR_RAMDISK_KERNEL_MODULES += $(first_stage_modules)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES += $(gki_modules)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES += $(second_stage_modules)

# DTBs
BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PREBUILT_DIR)/dtbs/dtbo.img
BOARD_PREBUILT_DTBIMAGE_DIR := $(KERNEL_PREBUILT_DIR)/dtbs/

# Prebuilt kernel
TARGET_PREBUILT_KERNEL := $(KERNEL_PREBUILT_DIR)/Image

# Kernel Headers
TARGET_BOARD_KERNEL_HEADERS := $(KERNEL_PREBUILT_DIR)/kernel-headers

# Kernel
PRODUCT_COPY_FILES += $(KERNEL_PREBUILT_DIR)/Image:kernel
PRODUCT_COPY_FILES += $(KERNEL_PREBUILT_DIR)/System.map:$(KERNEL_PRODUCT_DIR)/System.map
endif
