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

ui_print "- Copying Sweet2 GCam XML configuration..."
CONFIG_FILE="$MODPATH/common/GCam_Config_sweet2.xml"
if [ -f "$CONFIG_FILE" ]; then
  mkdir -p /sdcard/GCam/Configs9
  mkdir -p /sdcard/GCam/Configs8
  mkdir -p /sdcard/Download
  cp "$CONFIG_FILE" /sdcard/GCam/Configs9/GCam_Config_sweet2.xml 2>/dev/null || true
  cp "$CONFIG_FILE" /sdcard/GCam/Configs8/GCam_Config_sweet2.xml 2>/dev/null || true
  cp "$CONFIG_FILE" /sdcard/Download/GCam_Config_sweet2.xml 2>/dev/null || true
  cp "$CONFIG_FILE" /sdcard/Download/MGC.cfg 2>/dev/null || true

  ui_print "- Import the config from GCam/Configs9 after reboot."
fi

# Register and install Google Camera APK in PackageManager if system is running
if [ "$(getprop sys.boot_completed)" = "1" ]; then
  ui_print "- Registering Google Camera APK in PackageManager..."
  pm install -r -d -g "$MODPATH/system/product/app/GoogleCameraEng/GoogleCameraEng.apk" >/dev/null 2>&1 || pm install -r "$MODPATH/system/product/app/GoogleCameraEng/GoogleCameraEng.apk" >/dev/null 2>&1 || true
fi

ui_print "- Google Camera System App installed successfully!"
ui_print "- Please reboot your device to apply system app mounts."
