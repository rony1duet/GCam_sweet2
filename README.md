# GCam_sweet2 — Google Camera System Module

> **Google Camera (MGC 9.6.080) tuned for Redmi Note 12 Pro (sweet2 / Snapdragon 778G)**  
> Maintained by [rony1duet](https://github.com/rony1duet)

---

## 📋 Device Info

| Key | Value |
|-----|-------|
| **Device** | Redmi Note 12 Pro 4G |
| **Codename** | sweet2 |
| **SoC** | Snapdragon 778G |
| **Video default / maximum** | **1080p / 4K @ 30fps** |
| **GCam Version** | MGC 9.6.080_V52 |
| **Target ROM** | PixelOS (AOSP) |

---

## 🎯 Features

- ✅ Google Camera (MGC) installed as a **system app** (replaces stock Aperture)
- ✅ Sweet2-tuned `GCam_Config_sweet2.xml` with correct AWB, sharpness, noise reduction, HDR+
- ✅ **Video caps fixed** — defaults to **1080p**, supports up to **4K@30fps**, and hides **8K and 4K@60fps**
- ✅ 64-bit native libraries bundled (`arm64`)
- ✅ Aperture camera suppressed/replaced
- ✅ All runtime permissions auto-granted on boot
- ✅ Config bundled under `/product/etc/gcam/` for import in GCam

---

## 📹 Video Capability Fix (Key Change)

The Snapdragon 778G supports a maximum of **4K @ 30fps**. Previous configs incorrectly exposed 8K and 4K@60fps options in the GCam video menu.

**Fixed in `common/GCam_Config_sweet2.xml`:**
```xml
<!-- Disable 8K video option -->
<string name="pref_camera_video_8k_enabled">0</string>
<string name="pref_camera_video_8k_option_available">0</string>

<!-- Disable 4K@60fps (not supported) -->
<string name="pref_camera_video_4k60_enabled">0</string>
<string name="pref_camera_video_4k60_option_available">0</string>

<!-- Default to 1080p; 4K remains available at 30fps -->
<string name="pref_video_resolution">RES_1080P</string>
<string name="pref_video_fps_4k_key">FPS_30</string>
<string name="pref_camera_max_video_resolution">3840x2160</string>
```

---

## 🏗️ Repository Structure

```
GCam_sweet2/
├── Android.mk                      <- AOSP build integration
├── Android.bp                      <- Blueprint build file
├── README.md
├── module.prop                     <- Magisk/KernelSU module metadata
├── customize.sh                    <- Magisk install script
├── service.sh                      <- Post-boot service script
├── common/
│   └── GCam_Config_sweet2.xml      <- Tuned GCam preferences
├── system/
│   └── product/
│       └── app/
│           ├── GoogleCameraEng/
│           │   ├── GoogleCameraEng.apk
│           │   └── lib/arm64/      <- 64-bit native .so files
│           ├── Aperture/
│           │   └── .replace        <- Replaces stock Aperture
│           └── ApertureLensLauncher/
│               └── .replace
└── META-INF/
    └── com/google/android/
        ├── update-binary
        └── updater-script
```

---

## 🔧 AOSP / PixelOS Build Integration

### Method 1 — `PRODUCT_PACKAGES` in device tree

Add to your device tree's `device.mk` (or `device_sweet2.mk`):

```makefile
# Google Camera (MGC) as a product app
PRODUCT_PACKAGES += \
    GoogleCameraEng
```

Then inherit the product fragment:
```makefile
$(call inherit-product, vendor/GCam_sweet2/Android.mk)
```

`Android.bp` is the only module definition. It installs the APK plus the
config and permission XML as required dependencies; do not add duplicate
`PRODUCT_COPY_FILES` entries for them.

### Method 2 — Direct vendor include

In your `vendorsetup.sh` or ROM's `vendor/` directory, clone this repo:
```bash
git clone https://github.com/rony1duet/GCam_sweet2 vendor/GCam_sweet2
```

Then inherit the supplied device fragment from your device's `device.mk`:
```makefile
$(call inherit-product, vendor/GCam_sweet2/aosp/device_sweet2_gcam.mk)
```

### Method 3 — `.repo/local_manifests/` (recommended for PixelOS)

Create `.repo/local_manifests/gcam_sweet2.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="rony1duet"
          fetch="https://github.com/rony1duet/"
          revision="main" />

  <project path="vendor/GCam_sweet2"
           name="GCam_sweet2"
           remote="rony1duet"
           revision="main" />
</manifest>
```

Then sync:
```bash
repo sync vendor/GCam_sweet2
```

### Fetch the GCam prebuilt before building

The proprietary APK and its extracted native libraries are deliberately excluded
from Git. Fetch the pinned, verified prebuilt after `repo sync` and before
starting the PixelOS build:

```bash
bash vendor/GCam_sweet2/tools/fetch_gcam_prebuilt.sh
source build/envsetup.sh
lunch aosp_sweet2-userdebug
m bacon
```

The script downloads **MGC_9.6.080_V52_ENG.apk**, verifies its SHA-256, tests
the APK archive, and extracts its arm64 libraries into the source tree. It is
safe to run repeatedly and will not download again when the expected APK is
already present.

To use a trusted mirror or a GitHub Release asset without editing the script:

```bash
GCAM_APK_URL="https://example.com/MGC_9.6.080_V52_ENG.apk" \
bash vendor/GCam_sweet2/tools/fetch_gcam_prebuilt.sh
```

The hash check remains enabled. If you intentionally change the APK version,
update the version, URL, SHA-256, and build definitions together in one commit.

---

## 📦 Magisk / KernelSU Install

1. Download the module ZIP from [Releases](https://github.com/rony1duet/GCam_sweet2/releases)
2. Flash via Magisk / KernelSU / APatch
3. Reboot
4. Open Google Camera and import `GCam_Config_sweet2.xml` from `Configs9`

---

## 🔌 ADB Push (Manual Config Apply)

With your device connected via ADB (root):
```bash
adb push common/GCam_Config_sweet2.xml /sdcard/GCam/Configs9/
adb shell am force-stop com.google.android.GoogleCameraEng
```

Open Google Camera and use its config-import flow to load the file. Copying a
config XML directly into Android SharedPreferences is not supported: GCam
rewrites that file when it starts.

---

## 📄 License

Apache 2.0 — see [LICENSE](LICENSE)
