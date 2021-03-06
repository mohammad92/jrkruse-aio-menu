SKIPUNZIP=1

# Extract files
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" module.prop post-fs-data.sh system.prop -d $MODPATH >&2

ctsProfile() {
  # Bootloader string
  BL=$(getprop ro.boot.bootloader);
  # Device is first 5 characters of bootloader string.
  DEVICE=${BL:0:5};
  # Append a space to the device string.
  # Replace BASIC and append a space to the device string.
  sed -i "s/BASIC/ SM\-${DEVICE}/g" $MODPATH/system.prop;
}

# Paths
patched_keystore="$MODPATH/system/bin/keystore"
original_keystore="/bin/keystore"
replace_path="$MODPATH/system/bin"

# Hex pattern
pre="0074696d657374616d7000"
post="0000696d657374616d7000"

ui_print "- Start patching..."
mkdir -p $replace_path
cp -f -p $original_keystore $replace_path
set_perm_recursive $replace_path 0 0 0755 0755
if `/data/adb/magisk/magiskboot hexpatch $patched_keystore $pre $post` ; then
  ui_print "- Successfully patched keystore!"
elif [ -d "/data/adb/modules/hardwareoff" ]; then
  ui_print "- keystore already patched!"
else
  ui_print "- Not found hex pattern in keystore, Aborting..."
  rm -rf $MODPATH
  abort
fi

# Set executable permissions
set_perm_recursive "$MODPATH" 0 0 0755 0755

# Needed in Google's device-based testing stage.
ctsProfile
