#!/system/bin/sh
MODDIR=${0%/*}

# Wait for boot completion
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 2
done

# Ensure Aperture remains suppressed
pm disable-user --user 0 org.lineageos.aperture >/dev/null 2>&1

# Ensure Google Camera APK is registered in PackageManager
if ! pm path com.google.android.GoogleCameraEng >/dev/null 2>&1; then
  APK_CAND=""
  if [ -f "$MODDIR/system/product/app/GoogleCameraEng/GoogleCameraEng.apk" ]; then
    APK_CAND="$MODDIR/system/product/app/GoogleCameraEng/GoogleCameraEng.apk"
  elif [ -f "$MODDIR/product/app/GoogleCameraEng/GoogleCameraEng.apk" ]; then
    APK_CAND="$MODDIR/product/app/GoogleCameraEng/GoogleCameraEng.apk"
  fi
  if [ -n "$APK_CAND" ]; then
    pm install -r -d -g "$APK_CAND" >/dev/null 2>&1 || pm install -r "$APK_CAND" >/dev/null 2>&1 || true
  fi
fi

# Ensure Google Camera has all required runtime permissions
pm grant com.google.android.GoogleCameraEng android.permission.CAMERA >/dev/null 2>&1
pm grant com.google.android.GoogleCameraEng android.permission.RECORD_AUDIO >/dev/null 2>&1
pm grant com.google.android.GoogleCameraEng android.permission.ACCESS_FINE_LOCATION >/dev/null 2>&1
pm grant com.google.android.GoogleCameraEng android.permission.ACCESS_COARSE_LOCATION >/dev/null 2>&1
pm grant com.google.android.GoogleCameraEng android.permission.READ_MEDIA_IMAGES >/dev/null 2>&1
pm grant com.google.android.GoogleCameraEng android.permission.READ_MEDIA_VIDEO >/dev/null 2>&1
pm grant com.google.android.GoogleCameraEng android.permission.READ_EXTERNAL_STORAGE >/dev/null 2>&1
pm grant com.google.android.GoogleCameraEng android.permission.WRITE_EXTERNAL_STORAGE >/dev/null 2>&1
appops set com.google.android.GoogleCameraEng MANAGE_EXTERNAL_STORAGE allow >/dev/null 2>&1
