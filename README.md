# GCam for Redmi Note 12 Pro 4G (sweet2)

Google Camera (BSG MGC 9.6.080) tuned for Redmi Note 12 Pro 4G (`sweet2` / Qualcomm SM6150 / Snapdragon 732G).
Maintained by [rony1duet](https://github.com/rony1duet).

## Specifications

| Property | Details |
|:---|:---|
| **Device** | Redmi Note 12 Pro 4G (`sweet2`) |
| **Chipset** | Qualcomm SM6150 (Snapdragon 732G) |
| **Architecture** | 64-bit ARM (`arm64-v8a`) |
| **Main Sensor** | 108 MP (Samsung ISOCELL HM2, f/1.9) |
| **Aux Sensors** | 8 MP Ultra-Wide (Sony IMX355) + 2 MP Macro + 2 MP Depth |
| **Front Camera** | 16 MP (OmniVision OV16A1Q) |
| **GCam Build** | BSG MGC 9.6.080_V52_ENG (`com.google.android.GoogleCameraEng`) |
| **Video Modes** | 1080p @ 30/60 fps, 4K @ 30 fps (8K and 4K@60fps disabled) |
| **Compatibility** | PixelOS, LineageOS, AOSP (Android 14, 15, 16, 17) |

## Features

- Integrates directly into AOSP/PixelOS build trees via `Android.bp` as a product-privileged app.
- Configured with `dex_preopt: { enabled: false }` to avoid build-time `dex2oat` RAM exhaustion.
- Can be compiled into ROM images or flashed systemlessly via Magisk / KernelSU / APatch.
- Disables unsupported 8K and 4K@60fps video modes to prevent Snapdragon 732G ISP driver crashes.
- Includes `GCam_Config_sweet2.xml` with tuned black levels, noise reduction, and custom AWB for the HM2 sensor.
- Whitelists privileged permissions in `product/etc/permissions/privapp-permissions-GoogleCameraEng.xml`.
- Replaces stock Aperture camera packages when installed.

## Video Configuration (Spectra 350 Limits)

The Snapdragon 732G Spectra 350 ISP supports up to 4K at 30 fps and 1080p at 60 fps. Generic GCam ports often expose 8K or 4K@60fps, which crashes the camera HAL on SM6150.

Pinned settings in `common/GCam_Config_sweet2.xml`:
```xml
<!-- Disable unsupported video modes -->
<string name="pref_camera_video_8k_enabled">0</string>
<string name="pref_camera_video_8k_option_available">0</string>
<string name="pref_camera_video_4k60_enabled">0</string>
<string name="pref_camera_video_4k60_option_available">0</string>

<!-- Defaults: 1080p with selectable 4K@30 and 1080p@60 -->
<string name="pref_video_resolution">RES_1080P</string>
<string name="pref_video_fps_4k_key">FPS_30</string>
<string name="pref_camera_max_video_resolution">3840x2160</string>
```

## Project Layout

```text
GCam_sweet2/
├── Android.bp                              # Blueprint for GoogleCameraEng module
├── LICENSE                                 # Apache 2.0 license
├── module.prop                             # Magisk/KernelSU metadata
├── customize.sh                            # Module installer script
├── service.sh                              # Runtime permission enforcer
├── privapp-permissions-GoogleCameraEng.xml # System permissions whitelist
├── common/
│   └── GCam_Config_sweet2.xml              # sweet2 hardware config
├── aosp/
│   ├── device_sweet2_gcam.mk               # Makefile include for device tree
│   └── local_manifests/
│       └── gcam_sweet2.xml                 # Local manifest snippet
└── system/
    └── product/app/
        ├── GoogleCameraEng/                # Target app location
        ├── Aperture/.replace               # Masks stock Aperture
        └── ApertureLensLauncher/.replace   # Masks stock launcher shortcut
```

## ROM Integration

### 1. Local Manifest
Add to `.repo/local_manifests/sweet2.xml`:

```xml
<project path="vendor/GCam_sweet2"
         name="rony1duet/GCam_sweet2"
         remote="rem" revision="PixelOS-16-QPR2" clone-depth="1" />
<project path="vendor/android_prebuilts_sweet2"
         name="rony1duet/android_prebuilts_sweet2"
         remote="rem" revision="PixelOS-16-QPR2" clone-depth="1" />
```

### 2. Device Tree Makefile
Include the package in `device/xiaomi/sweet2/device.mk`:

```makefile
$(call inherit-product-if-exists, vendor/GCam_sweet2/aosp/device_sweet2_gcam.mk)
```

Remove default Aperture in `custom_sweet2.mk`:
```makefile
PRODUCT_PACKAGES_REMOVE += \
    Aperture \
    ApertureLensLauncher
```

### 3. Fetch Prebuilt APK
The ~342MB APK and native libraries are gitignored. Download before compiling:

```bash
bash vendor/android_prebuilts_sweet2/gcam/fetch_gcam_prebuilt.sh \
    vendor/GCam_sweet2/system/product/app/GoogleCameraEng
```

### 4. Build
```bash
source build/envsetup.sh
breakfast sweet2
m pixelos
```

## Magisk / KernelSU Module Install

For devices running an existing custom ROM:

1. Download the module zip from [Releases](https://github.com/rony1duet/GCam_sweet2/releases).
2. Open **KernelSU**, **Magisk**, or **APatch**.
3. Select **Install from storage** and choose the zip.
4. Reboot the device.
5. In Google Camera, double-tap the area around the shutter button to load `GCam_Config_sweet2.xml`.

## Manual ADB Testing

To push configs directly to a connected rooted device:

```bash
# Push config file
adb push common/GCam_Config_sweet2.xml /sdcard/GCam/Configs9/
adb push common/GCam_Config_sweet2.xml /sdcard/Download/

# Restart camera app
adb shell am force-stop com.google.android.GoogleCameraEng

# Grant runtime permissions
adb shell pm grant com.google.android.GoogleCameraEng android.permission.CAMERA
adb shell pm grant com.google.android.GoogleCameraEng android.permission.RECORD_AUDIO
adb shell pm grant com.google.android.GoogleCameraEng android.permission.ACCESS_FINE_LOCATION
adb shell pm grant com.google.android.GoogleCameraEng android.permission.READ_MEDIA_IMAGES
adb shell pm grant com.google.android.GoogleCameraEng android.permission.READ_MEDIA_VIDEO
```

## Tested Features

- [x] Portrait mode with depth mapping and face retouching
- [x] 1080p video recording at 30 and 60 fps
- [x] 4K video recording at 30 fps with EIS
- [x] 108MP sensor with pixel binning and HDR+
- [x] Night Sight and Astrophotography
- [x] Lens switching between Primary, Ultra-Wide, and Macro

## License

Licensed under [Apache 2.0](LICENSE).
GCam binaries are property of Google LLC and modded by BSG / MGC.
