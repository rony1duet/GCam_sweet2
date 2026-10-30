# device_sweet2_gcam.mk
# Include this file from your device tree's device.mk:
#   $(call inherit-product-if-exists, vendor/GCam_sweet2/aosp/device_sweet2_gcam.mk)

# -------------------------------------------------------
# Google Camera (MGC 9.6.080) as a product privileged app
# Replaces stock Aperture camera
# -------------------------------------------------------

# Add the Soong-defined GCam package. Android.bp also installs the config and
# privapp-permissions XML through the app's `required` dependencies.
PRODUCT_PACKAGES += \
    GoogleCameraEng

# Suppress stock Aperture camera (replaced by GCam)
# Uncomment if Aperture is defined in your device tree:
# PRODUCT_PACKAGES_ENG += GoogleCameraEng
# REMOVE_PACKAGES += Aperture ApertureLensLauncher
