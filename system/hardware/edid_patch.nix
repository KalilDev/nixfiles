{pkgs, lib, config, ...}: let
  mkOverrideScriptName = (identifier: "override-edid-${lib.strings.replaceString ":" "-" identifier}");
  mkOverrideScript = (script-name: identifier: {edid, connector}: pkgs.writeShellScript "${script-name}" ''
set -euo pipefail

TARGET_DISPLAY_IDENTIFIER="${identifier}"
TARGET_DISPLAY_CONN_TYPE="${if (builtins.isNull connector) then "" else "${connector}"}"
TARGET_DISPLAY_EDID_PATH="${edid}"

# Expected argument: "card0/DP/1" or similar
CONNECTOR_PATH="$1"

# Extract card name and connector name from the udev instance string
# e.g., card0-DP-1 splits into card=card0, conn=DP-1
CARD=$(echo "$CONNECTOR_PATH" | cut -d'/' -f1)
CARD_PFX=$(echo "$CARD" | head -c 4)
CARD_NO=$(echo "$CARD" | cut -c 5-)
CONN=$(echo "$CONNECTOR_PATH" | cut -d'/' -f2-)
CONN_TYPE=$(echo "$CONN" | cut -d'/' -f1)
CONN_NO=$(echo "$CONN" | cut -d'/' -f2)

if [ ! -f "$TARGET_DISPLAY_EDID_PATH" ]; then
    echo "Target edid override file at path '$TARGET_DISPLAY_EDID_PATH' doesn't exist!"
    exit 1
fi

if [ ! -z "$TARGET_DISPLAY_CONN_TYPE" ] && [ "$TARGET_DISPLAY_CONN_TYPE" != "$CONN_TYPE" ]; then
    echo "Connector type not matched! Expecting '$TARGET_DISPLAY_CONN_TYPE', got '$CONN_TYPE'"
    exit 0
fi

if [ "$CARD_PFX" != "card" ] || [[ ! "$CARD_NO" =~ ^[0-9]+$ ]]; then
    echo "Expected card\\d+ formatted card, got '$CARD'"
    exit 0
fi

if [ "$CARD" == "$CONN" ] || [ -z "$CONN" ]; then
    echo "Expected $CARD-\$CONNECTOR, got just $CARD"
    exit 0
fi

DEBUGFS_BASE="/sys/kernel/debug/dri"
DEBUGFS_CONN_DIR="$DEBUGFS_BASE/$CARD_NO/$CONN_TYPE-$CONN_NO"
SYSFS_BASE="/sys/class/drm"
SYSFS_CONN_DIR="$SYSFS_BASE/$CARD-$CONN_TYPE-$CONN_NO"

# If debugfs uses a different naming structure, fallback search:
if [ ! -d "$DEBUGFS_CONN_DIR" ]; then
    echo "Didn't find the debugfs connection directory, expected at '$DEBUGFS_CONN_DIR'!"
    exit 1
fi
if [ ! -d "$SYSFS_CONN_DIR" ]; then
    echo "Didn't find the sysfs connection directory, expected at '$SYSFS_CONN_DIR'!"
    exit 1
fi
# Exit early if the connector directory or raw edid file isn't present yet
if [ ! -f "$SYSFS_CONN_DIR/edid" ] || [ ! $(cat "$SYSFS_CONN_DIR/edid" | wc -c) -gt 0 ]; then
    echo "Connector EDID file not found or empty for $CONNECTOR_PATH. Exiting."
    exit 0
fi
if [ ! -f "$DEBUGFS_CONN_DIR/edid_override" ]; then
    echo "Connector EDID override file not found for $CONNECTOR_PATH. Exiting."
    exit 0
fi

get_16_bytes_from_edid() {
    dd if="$SYSFS_CONN_DIR/edid" ibs=1 skip=''${1:0} count=2 2>/dev/null | xxd -e -c 0 | cut -F2 | tr -d '\n'
}
get_16_bytes_from_override_edid() {
    dd if="$TARGET_DISPLAY_EDID_PATH" ibs=1 skip=''${1:0} count=2 2>/dev/null | xxd -e -c 0 | cut -F2 | tr -d '\n'
}

VENDOR_ID=$(get_16_bytes_from_edid 8)
DEVICE_ID=$(get_16_bytes_from_edid 10)
DISPLAY_IDENTIFIER="$VENDOR_ID:$DEVICE_ID"
OVERRIDE_DISPLAY_IDENTIFIER="$(get_16_bytes_from_override_edid 8):$(get_16_bytes_from_override_edid 10)"

if [ -z "$VENDOR_ID" ] || [ -z "$DEVICE_ID" ]; then
    echo "Could not detect vendor id (encoded 3 letter UEFI vendor name in 2 byte edid format) + device id combo from edid!"
    exit 1
fi

echo "Detected display '$DISPLAY_IDENTIFIER' at connector '$CONN_NO' of type '$CONN_TYPE' in card '$CARD_NO'"

if [ "$TARGET_DISPLAY_IDENTIFIER" != "$DISPLAY_IDENTIFIER" ]; then
    echo "Didn't match the expected display '$TARGET_DISPLAY_IDENTIFIER'"
    exit 0
fi
if [ "$OVERRIDE_DISPLAY_IDENTIFIER" != "$DISPLAY_IDENTIFIER" ]; then
    echo "SANITY_CHECK: The override edid display identifier '$OVERRIDE_DISPLAY_IDENTIFIER' didn't match the display's identifier '$DISPLAY_IDENTIFIER'!"
    echo "SANITY_CHECK: Aborting!"
    exit 1
fi

WANTED_MD5=$(cat "$TARGET_DISPLAY_EDID_PATH" | md5sum -b | cut -F1)
CURRENT_MD5=$(cat "$SYSFS_CONN_DIR/edid" | md5sum -b | cut -F1)

if [ "$WANTED_MD5" == "$CURRENT_MD5" ]; then
    echo "The current edid for this display already matches the forced edid!"
    exit 0
fi

echo "Overriding edid with $TARGET_DISPLAY_EDID_PATH"

cat "$TARGET_DISPLAY_EDID_PATH" > "$DEBUGFS_CONN_DIR/edid_override"
echo "Overrode edid!"

echo detect > "/sys/class/drm/$CARD-$CONN_TYPE-$CONN_NO/status"

#if [ -f "$DEBUGFS_CONN_DIR/trigger_hotplug" ]; then
#    echo 1 > "$DEBUGFS_CONN_DIR/trigger_hotplug"
echo "Triggered hotplug!"
#fi

exit 0
      '');
  mkOverrideServiceName = (identifier: "override-edid-${lib.strings.replaceString ":" "-" identifier}@");
  mkOverrideServiceUnit = (identifier: options: let
   scriptName = (mkOverrideScriptName identifier);
  in {
    description = "Runtime edid overriding for display ${identifier} in connector %I";
    after = [ "local-fs.target" ];
    path = [ pkgs.coreutils-full pkgs.xxd ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mkOverrideScript scriptName identifier options} %I";
      RemainAfterExit = false;
    };
  });
  mkOverrideUdevRule = (identifier: options: ''ACTION=="change", SUBSYSTEM=="drm", KERNEL=="card[0-9]-*", ENV{SYSTEMD_WANTS}+="${mkOverrideServiceName identifier}%k.service"'');
  cfg = config.services.runtime-override-edid;
  display-config = lib.types.attrsOf (lib.types.submodule {
    options = {
      edid = lib.mkOption { type = lib.types.str; description = "A path to the wanted patched edid"; };
      connector = lib.mkOption {type = lib.types.nullOr lib.types.str; description = "A connector you want to match to, other than just the vendor id + device id combo"; default = null;};
    };
  });
in {
  options.services.runtime-override-edid = {
    enable = lib.mkEnableOption "Enable edid overriding for specific vendor:display-connector combos";
    displays = lib.mkOption {
      type = display-config;
      default = {};
      description = "A key value pair from a display vendor_id:device_id to a edid override configuration";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services = lib.mapAttrs' (identifier: options: lib.nameValuePair "${mkOverrideServiceName identifier}" (mkOverrideServiceUnit identifier options)) cfg.displays;
    services.udev.extraRules = lib.strings.join "\n" (lib.mapAttrsToList mkOverrideUdevRule cfg.displays);
  };
}
