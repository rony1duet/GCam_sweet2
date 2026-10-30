# GCam_sweet2 — Google Camera System Module & AOSP Integration

> **Google Camera (BSG MGC 9.6.080) tuned for Redmi Note 12 Pro 4G (`sweet2` / Qualcomm SM6150 / Snapdragon 732G)**  
> Maintained by [Md Rony Hossen (rony1duet)](https://github.com/rony1duet)

---

## 📋 Device & Technical Specifications

| Property | Value |
|:---|:---|
| **Device Model** | Redmi Note 12 Pro 4G |
| **Codename** | `sweet2` |
| **SoC / Chipset** | Qualcomm SM6150 (Snapdragon 732G, 8nm) |
| **Architecture** | 64-bit ARM (`arm64-v8a`) |
| **Main Camera Sensor** | 108 MP (Samsung ISOCELL HM2, $1/1.52"$, f/1.9) |
| **Auxiliary Sensors** | 8 MP (Sony IMX355 / S5K4H7 Ultra-Wide) + 2 MP (Macro) + 2 MP (Depth) |
| **Front Camera** | 16 MP (OmniVision OV16A1Q) |
| **GCam Engine** | BSG MGC 9.6.080_V52_ENG (`com.google.android.GoogleCameraEng`) |
| **Video Configurations** | **1080p @ 30/60 fps**, **4K @ 30 fps** (8K & 4K@60fps disabled) |
| **Target Platforms** | PixelOS, LineageOS, AOSP (Android 14, 15, 16, 17) |

---

## 🎯 Key Features & Optimizations

- 📸 **Native AOSP & PixelOS Integration**: Integrates directly into ROM compilation trees using Blueprint (`Android.bp`) as a product-privileged package.
- ⚡ **Build-Ready & Dexpreopt Safe**: Configured with `dex_preopt: { enabled: false }` to prevent build-time `dex2oat` RAM exhaustion (OOM) on CI containers like Crave.
- 📦 **Dual Deployment Mode**: Can be built directly into the system image or installed systemlessly as a Magisk / KernelSU / APatch module.
- 🎬 **Hardware-Accurate Video Profiles**: Corrects the Snapdragon 732G Spectra 350 ISP limits. Prevents app crashes by disabling unsupported 8K and 4K@60fps modes while retaining full 4K@30fps and FHD@60fps capture.
- 🎨 **Tuned Color & Noise Calibration**: Includes `GCam_Config_sweet2.xml` pre-tuned for Samsung HM2 sensor black levels, noise reduction, and custom Google AWB.
- 🛡️ **Privileged Permissions Whitelisted**: Bundles `/product/etc/permissions/privapp-permissions-GoogleCameraEng.xml` for full access to camera hardware, audio, fine location, and external storage.
- 🚫 **Stock Camera Replacement**: Cleanly suppresses default Aperture / ApertureLensLauncher camera packages.

---

## 📹 Video Profile Tuning (Spectra 350 ISP Limits)

The Qualcomm Snapdragon 732G Spectra 350 ISP hardware supports up to **4K at 30 fps** and **1080p at 60 fps**. Generic GCam ports often expose 8K and 4K@60fps options which crash the camera stack on SM6150.

**Pinned configuration in `common/GCam_Config_sweet2.xml`:**
```xml
<!-- Disable unsupported 8K video -->
<string name="pref_camera_video_8k_enabled">0</string>
<string name="pref_camera_video_8k_option_available">0</string>

<!-- Disable unsupported 4K @ 60fps -->
<string name="pref_camera_video_4k60_enabled">0</string>
<string name="pref_camera_video_4k60_option_available">0</string>

<!-- Default to 1080p with 4K@30fps and 1080p@60fps selectable -->
<string name="pref_video_resolution">RES_1080P</string>
<string name="pref_video_fps_4k_key">FPS_30</string>
<string name="pref_camera_max_video_resolution">3840x2160</string>
```

---

## 🏗️ Repository Architecture

```text
GCam_sweet2/
├── Android.bp                                 # Soong blueprint (GoogleCameraEng module)
├── README.md                                  # Comprehensive documentation
├── LICENSE                                    # Apache 2.0 license
├── module.prop                                # Magisk / KernelSU module metadata
├── customize.sh                               # Magisk / KernelSU installer script
├── service.sh                                 # Post-boot permissions & appops enforcer
├── privapp-permissions-GoogleCameraEng.xml    # System privileged permissions whitelist
├── common/
│   └── GCam_Config_sweet2.xml                 # Sweet2 hardware-tuned XML configuration
├── aosp/
│   ├── device_sweet2_gcam.mk                  # Makefile fragment for device tree include
│   └── local_manifests/
│       └── gcam_sweet2.xml                    # Repo manifest entry for PixelOS / AOSP
├── system/
│   ├── product/
│   │   └── app/
│   │       ├── GoogleCameraEng/
│   │       │   ├── GoogleCameraEng.apk        # (Fetched by fetch_gcam_prebuilt.sh)
│   │       │   └── lib/arm64/*.so             # (Extracted native arm64 shared libs)
│   │       ├── Aperture/
│   │       │   └── .replace                   # Masks stock Aperture
│   │       └── ApertureLensLauncher/
│   │           └── .replace                   # Masks stock Aperture lens shortcut
│   └── system_ext/
│       └── app/
│           └── Aperture/
│               └── .replace                   # Masks Aperture in system_ext partition
└── META-INF/
    └── com/google/android/
        ├── update-binary                      # Module flash script entry
        └── updater-script                     # Dummy updater binary
```

---

## 🔧 AOSP & PixelOS ROM Build Integration

### 1. Local Manifest Configuration
Add the repository to `.repo/local_manifests/sweet2.xml`:

```xml
<!-- Google Camera for sweet2 -->
<project path="vendor/GCam_sweet2"
         name="rony1duet/GCam_sweet2"
         remote="rem" revision="PixelOS-17-base" clone-depth="1" />

<!-- Shared Prebuilt Fetcher -->
<project path="vendor/android_prebuilts_sweet2"
         name="rony1duet/android_prebuilts_sweet2"
         remote="rem" revision="PixelOS-17-base" clone-depth="1" />
```

### 2. Device Tree Makefile Inheritance
Include the GCam fragment inside `device/xiaomi/sweet2/device.mk`:

```makefile
# Google Camera
$(call inherit-product-if-exists, vendor/GCam_sweet2/aosp/device_sweet2_gcam.mk)
```

Stock Aperture removal is handled cleanly via `custom_sweet2.mk`:
```makefile
PRODUCT_PACKAGES_REMOVE += \
    Aperture \
    ApertureLensLauncher
```

### 3. Build-Time Prebuilt Fetcher
The ~342 MB proprietary APK and extracted native libraries are gitignored to keep repository sizes small. Fetch the verified prebuilt prior to initiating the build:

```bash
bash vendor/android_prebuilts_sweet2/gcam/fetch_gcam_prebuilt.sh \
    vendor/GCam_sweet2/system/product/app/GoogleCameraEng
```

### 4. Compile the ROM
```bash
source build/envsetup.sh
breakfast sweet2
m pixelos
```

---

## 📦 Magisk / KernelSU / APatch Module Installation

For devices already running a custom ROM without built-in GCam:

1. Download the latest module ZIP from the [Releases](https://github.com/rony1duet/GCam_sweet2/releases) tab.
2. Open **KernelSU**, **Magisk**, or **APatch** application.
3. Navigate to the **Modules** section and select **Install from storage**.
4. Select the downloaded `.zip` file.
5. `customize.sh` will automatically:
   - Suppress stock Aperture camera packages.
   - Set optimal `0644` file and `0755` executable permissions for all 21 bundled arm64 libraries.
   - Copy `GCam_Config_sweet2.xml` into `/sdcard/GCam/Configs9/` and `/sdcard/Download/`.
6. Reboot your device.
7. Open **Google Camera** and double-tap the black bar around the shutter button to import `GCam_Config_sweet2.xml`.

---

## 🔌 ADB Manual Testing & Config Deployment

To manually push and test configurations on a connected rooted device:

```bash
# Push the tuned configuration XML
adb push common/GCam_Config_sweet2.xml /sdcard/GCam/Configs9/
adb push common/GCam_Config_sweet2.xml /sdcard/Download/

# Stop running GCam instance to apply changes
adb shell am force-stop com.google.android.GoogleCameraEng

# Ensure runtime permissions are granted
adb shell pm grant com.google.android.GoogleCameraEng android.permission.CAMERA
adb shell pm grant com.google.android.GoogleCameraEng android.permission.RECORD_AUDIO
adb shell pm grant com.google.android.GoogleCameraEng android.permission.ACCESS_FINE_LOCATION
adb shell pm grant com.google.android.GoogleCameraEng android.permission.READ_MEDIA_IMAGES
adb shell pm grant com.google.android.GoogleCameraEng android.permission.READ_MEDIA_VIDEO
```

---

## 🧪 Validated Features on sweet2 Hardware

- [x] **Portrait Mode**: Bokeh depth calculation and edge detection working with face beauty options.
- [x] **Video Recording (1080p @ 30/60 fps)**: High-speed smooth playback verified without frame dropping.
- [x] **Video Recording (4K @ 30 fps)**: Ultra-HD recording operational with hardware video stabilization (EIS).
- [x] **108 MP Sensor Full Resolution**: Supported via sensor binning and enhanced HDR+ processing.
- [x] **Night Sight & Astrophotography**: Extended exposure and de-noise tuning operational.
- [x] **Macro & Ultra-Wide Aux Switching**: Smooth switching between all available physical lenses.

---

## 📄 License

Licensed under the [Apache License, Version 2.0](LICENSE).
GCam binary application is proprietary to Google LLC and modded by BSG / MGC.
