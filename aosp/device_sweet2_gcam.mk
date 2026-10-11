# device_sweet2_gcam.mk
# Include this file from your device tree's device.mk:
#   $(call inherit-product, vendor/GCam_sweet2/aosp/device_sweet2_gcam.mk)
#
# OR manually copy-paste the relevant lines into your device's device.mk

# -------------------------------------------------------
# Google Camera (MGC 9.6.080) as a product privileged app
# Replaces stock Aperture camera
# -------------------------------------------------------

# Add the Soong-defined GCam package. Android.bp also installs the config and
# privapp-permissions XML through the app's `required` dependencies.
$(call inherit-product, vendor/GCam_sweet2/Android.mk)

# Suppress stock Aperture camera (replaced by GCam)
# Uncomment if Aperture is defined in your device tree:
# PRODUCT_PACKAGES_ENG += GoogleCameraEng
# REMOVE_PACKAGES += Aperture ApertureLensLauncher
