$(TARGET_OUT_VENDOR)/firmware/wlan/qca_cld/kiwi_v2/WCNSS_qcom_cfg.ini: $(LOCAL_INSTALLED_MODULE)
$(call symlink-file,,/vendor/etc/wifi/kiwi_v2/WCNSS_qcom_cfg.ini,$(TARGET_OUT_VENDOR)/firmware/wlan/qca_cld/kiwi_v2/WCNSS_qcom_cfg.ini)
ALL_DEFAULT_INSTALLED_MODULES += $(TARGET_OUT_VENDOR)/firmware/wlan/qca_cld/kiwi_v2/WCNSS_qcom_cfg.ini
$(TARGET_OUT_VENDOR)/firmware/wlan/qca_cld/kiwi_v2/wlan_mac.bin: $(LOCAL_INSTALLED_MODULE)
$(call symlink-file,,/mnt/vendor/persist/kiwi_v2/wlan_mac.bin,$(TARGET_OUT_VENDOR)/firmware/wlan/qca_cld/kiwi_v2/wlan_mac.bin)
ALL_DEFAULT_INSTALLED_MODULES += $(TARGET_OUT_VENDOR)/firmware/wlan/qca_cld/kiwi_v2/wlan_mac.bin
$(TARGET_OUT_VENDOR)/firmware/wlanmdsp.otaupdate: $(LOCAL_INSTALLED_MODULE)
$(call symlink-file,,/data/vendor/firmware/wlanmdsp.mbn,$(TARGET_OUT_VENDOR)/firmware/wlanmdsp.otaupdate)
ALL_DEFAULT_INSTALLED_MODULES += $(TARGET_OUT_VENDOR)/firmware/wlanmdsp.otaupdate
