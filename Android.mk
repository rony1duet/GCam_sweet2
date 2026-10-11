# Android.mk for GCam_sweet2
# Include this from your device's device.mk:
#   $(call inherit-product, vendor/GCam_sweet2/Android.mk)
#
# Or add to PRODUCT_PACKAGES via BoardConfig / device.mk

LOCAL_PATH := $(call my-dir)

# -------------------------------------------------------
# GoogleCameraEng as a prebuilt system app
# -------------------------------------------------------
include $(CLEAR_VARS)
LOCAL_MODULE        := GoogleCameraEng
LOCAL_MODULE_CLASS  := APPS
LOCAL_MODULE_TAGS   := optional
LOCAL_BUILT_MODULE_STEM := package.apk
LOCAL_MODULE_SUFFIX := .apk
LOCAL_CERTIFICATE   := platform
LOCAL_PRIVILEGED_MODULE := true
LOCAL_SRC_FILES     := system/product/app/GoogleCameraEng/GoogleCameraEng.apk
LOCAL_MODULE_PATH   := $(TARGET_OUT_PRODUCT)/app/GoogleCameraEng

# Bundle 64-bit native libraries
LOCAL_PREBUILT_JNI_LIBS := \
    lib/arm64/libandroidx.graphics.path.so \
    lib/arm64/libannexbtoavcc.so \
    lib/arm64/libarcore_sdk_c.so \
    lib/arm64/libarcore_sdk_jni.so \
    lib/arm64/libbrotli.so \
    lib/arm64/libcyclops.so \
    lib/arm64/libeglimage.so \
    lib/arm64/libgcastartup.so \
    lib/arm64/libhotshot_object_detector_jni.so \
    lib/arm64/libimage.so \
    lib/arm64/libl2l_video_processor_utils_jni.so \
    lib/arm64/liblightcycle.so \
    lib/arm64/libnative.so \
    lib/arm64/libnative_crash_handler_jni.so \
    lib/arm64/libnative_utils_android.so \
    lib/arm64/liboliveoil.so \
    lib/arm64/libpairipcore.so \
    lib/arm64/libsaliency_predictor_jni.so \
    lib/arm64/libsegmentation_predictor_jni.so \
    lib/arm64/libsmartcapture_native.so \
    lib/arm64/libspeechenhancer_jni_avenhrealtimenative.so

include $(BUILD_PREBUILT)

# -------------------------------------------------------
# Copy GCam sweet2 config to product partition
# -------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/common/GCam_Config_sweet2.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/gcam/GCam_Config_sweet2.xml

# -------------------------------------------------------
# Replace / suppress stock Aperture camera
# -------------------------------------------------------
PRODUCT_PACKAGES += \
    GoogleCameraEng

# Remove Aperture from product packages if it was included
PRODUCT_PACKAGES_ENG += \
    GoogleCameraEng
