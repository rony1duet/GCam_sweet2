# device_sweet2_gcam.mk
# Include this file from your device tree's device.mk:
#   $(call inherit-product, vendor/GCam_sweet2/aosp/device_sweet2_gcam.mk)
#
# OR manually copy-paste the relevant lines into your device's device.mk

# -------------------------------------------------------
# Google Camera (MGC 9.6.080) as system app
# Replaces stock Aperture camera
# -------------------------------------------------------

# Include GCam AOSP build rules
$(call inherit-product, vendor/GCam_sweet2/Android.mk)

# Register GCam as a product package
PRODUCT_PACKAGES += \
    GoogleCameraEng

# Copy GCam sweet2 tuning config to /product/etc/gcam/
PRODUCT_COPY_FILES += \
    vendor/GCam_sweet2/common/GCam_Config_sweet2.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/gcam/GCam_Config_sweet2.xml

# Copy privileged permissions whitelist
PRODUCT_COPY_FILES += \
    vendor/GCam_sweet2/privapp-permissions-GoogleCameraEng.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-GoogleCameraEng.xml

# Suppress stock Aperture camera (replaced by GCam)
# Uncomment if Aperture is defined in your device tree:
# PRODUCT_PACKAGES_ENG += GoogleCameraEng
# REMOVE_PACKAGES += Aperture ApertureLensLauncher
