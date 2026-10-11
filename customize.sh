ui_print "**************************************************"
ui_print "      Google Camera (MGC) System App Module       "
ui_print "      Tuned for Redmi Note 12 Pro (sweet2)         "
ui_print "      Maintained by Md Rony Hossen (rony1duet)    "
ui_print "**************************************************"

ui_print "- Masking stock Aperture camera..."
pm disable-user --user 0 org.lineageos.aperture >/dev/null 2>&1
pm uninstall -k --user 0 org.lineageos.aperture >/dev/null 2>&1

ui_print "- Setting module permissions..."
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/system/product/app/GoogleCameraEng/GoogleCameraEng.apk 0 0 0644
set_perm_recursive $MODPATH/system/product/app/GoogleCameraEng/lib 0 0 0755 0644

ui_print "- Importing Sweet (k6a) GCam XML Configuration..."
CONFIG_FILE="$MODPATH/common/GCam_Config_sweet2.xml"
if [ -f "$CONFIG_FILE" ]; then
  mkdir -p /sdcard/GCam/Configs9
  mkdir -p /sdcard/GCam/Configs8
  mkdir -p /sdcard/Download
  cp "$CONFIG_FILE" /sdcard/GCam/Configs9/GCam_Config_sweet2.xml 2>/dev/null || true
  cp "$CONFIG_FILE" /sdcard/GCam/Configs8/GCam_Config_sweet2.xml 2>/dev/null || true
  cp "$CONFIG_FILE" /sdcard/Download/GCam_Config_sweet2.xml 2>/dev/null || true
  cp "$CONFIG_FILE" /sdcard/Download/MGC.cfg 2>/dev/null || true

  # Direct preference injection if package directory exists
  PREFS_DIR="/data/data/com.google.android.GoogleCameraEng/shared_prefs"
  if [ -d "/data/data/com.google.android.GoogleCameraEng" ]; then
    mkdir -p "$PREFS_DIR"
    GCAM_UID=$(stat -c "%u" /data/data/com.google.android.GoogleCameraEng 2>/dev/null || echo "10000")
    cp "$CONFIG_FILE" "$PREFS_DIR/com.google.android.GoogleCameraEng_preferences.xml"
    chown -R "$GCAM_UID:$GCAM_UID" "$PREFS_DIR" 2>/dev/null || true
    chmod 660 "$PREFS_DIR/com.google.android.GoogleCameraEng_preferences.xml" 2>/dev/null || true
    restorecon -R /data/data/com.google.android.GoogleCameraEng 2>/dev/null || true
    ui_print "- Configuration applied directly to camera preferences!"
  fi
fi

# Register and install Google Camera APK in PackageManager if system is running
if [ "$(getprop sys.boot_completed)" = "1" ]; then
  ui_print "- Registering Google Camera APK in PackageManager..."
  pm install -r -d -g "$MODPATH/system/product/app/GoogleCameraEng/GoogleCameraEng.apk" >/dev/null 2>&1 || pm install -r "$MODPATH/system/product/app/GoogleCameraEng/GoogleCameraEng.apk" >/dev/null 2>&1 || true
fi

ui_print "- Google Camera System App installed successfully!"
ui_print "- Please reboot your device to apply system app mounts."
