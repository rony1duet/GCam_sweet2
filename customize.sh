#!/system/bin/sh
# customize.sh - Magisk / KernelSU / APatch Module Installer
# Google Camera (MGC 9.6.080) for Redmi Note 12 Pro 4G (sweet2)

ui_print "**************************************************"
ui_print "      Google Camera (MGC) System App Module       "
ui_print "    Redmi Note 12 Pro 4G (sweet2 / SM6150)        "
ui_print "      Maintained by Md Rony Hossen (rony1duet)    "
ui_print "**************************************************"

# 1. Mask stock Aperture camera if present
ui_print "- Masking stock Aperture camera..."
pm disable-user --user 0 org.lineageos.aperture >/dev/null 2>&1 || true
pm disable-user --user 0 org.lineageos.aperture.dev >/dev/null 2>&1 || true
pm uninstall -k --user 0 org.lineageos.aperture >/dev/null 2>&1 || true
pm uninstall -k --user 0 org.lineageos.aperture.dev >/dev/null 2>&1 || true

# 2. Set module permissions
ui_print "- Setting module file permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644

# Set executable bit on post-boot scripts
if [ -f "$MODPATH/service.sh" ]; then
  set_perm "$MODPATH/service.sh" 0 0 0755
fi

# Set permissions for APK and bundled native libraries
APK_FILE="$MODPATH/system/product/app/GoogleCameraEng/GoogleCameraEng.apk"
LIB_DIR="$MODPATH/system/product/app/GoogleCameraEng/lib"

if [ -f "$APK_FILE" ]; then
  set_perm "$APK_FILE" 0 0 0644
fi
if [ -d "$LIB_DIR" ]; then
  set_perm_recursive "$LIB_DIR" 0 0 0755 0755
fi

# 3. Deploy GCam configuration XML to internal storage
ui_print "- Deploying Sweet2 GCam XML configuration..."
CONFIG_FILE="$MODPATH/common/GCam_Config_sweet2.xml"

# Resolve target storage directories (handles Android OS and recovery mounts)
TARGET_STORAGE=""
for candidate in "/sdcard" "/data/media/0" "/storage/emulated/0"; do
  if [ -d "$candidate" ]; then
    TARGET_STORAGE="$candidate"
    break
  fi
done

if [ -f "$CONFIG_FILE" ] && [ -n "$TARGET_STORAGE" ]; then
  mkdir -p "$TARGET_STORAGE/GCam/Configs9"
  mkdir -p "$TARGET_STORAGE/GCam/Configs8"
  mkdir -p "$TARGET_STORAGE/Download"
  cp "$CONFIG_FILE" "$TARGET_STORAGE/GCam/Configs9/GCam_Config_sweet2.xml" 2>/dev/null || true
  cp "$CONFIG_FILE" "$TARGET_STORAGE/GCam/Configs8/GCam_Config_sweet2.xml" 2>/dev/null || true
  cp "$CONFIG_FILE" "$TARGET_STORAGE/Download/GCam_Config_sweet2.xml" 2>/dev/null || true
  cp "$CONFIG_FILE" "$TARGET_STORAGE/Download/MGC.cfg" 2>/dev/null || true
  ui_print "  -> Config copied to GCam/Configs9 and Download/"
fi

# 4. Register APK if system is currently booted
if [ "$(getprop sys.boot_completed)" = "1" ] && [ -f "$APK_FILE" ]; then
  ui_print "- Registering Google Camera in PackageManager..."
  pm install -r -d -g "$APK_FILE" >/dev/null 2>&1 || pm install -r "$APK_FILE" >/dev/null 2>&1 || true
fi

ui_print "**************************************************"
ui_print " Installation complete!"
ui_print " 1. Reboot your device to apply system app mounts."
ui_print " 2. Open Google Camera and import the config from"
ui_print "    /sdcard/GCam/Configs9/GCam_Config_sweet2.xml"
ui_print "**************************************************"
