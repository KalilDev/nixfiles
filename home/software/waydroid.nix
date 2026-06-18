{config, lib, pkgs, ...}: {
  options.custom.waydroid-desktops = {
    hide = lib.mkOption {
      type = lib.types.bool;
      default = false;
    }; 
    whitelist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };
  config = let
    custom = config.custom;
    hide = custom.waydroid-desktops.hide;
    whitelist = custom.waydroid-desktops.whitelist;
  in lib.mkIf hide {
    systemd.user.timers.waydroid-desktop-file-hider = {
      Unit = {
        Description = "A timer that triggers every 5min when waydroid is running to cleanup the .desktop file mess.";
      };
      Timer = {
        OnBootSec = "2min";
        OnUnitActiveSec = "15min";
        Unit = "waydroid-desktop-file-hider.service";
      };
      Install = {
        WantedBy = ["timers.target"];
      };
    };
    systemd.user.services.waydroid-desktop-file-hider = let
     desktopExpr = expr: ''"$XDG_DATA_HOME"/applications/waydroid.${expr}.desktop'';
     fileHiderScript = pkgs.writeShellScriptBin "hide-waydroid-files.sh" ''
# Hide all
${pkgs.coreutils}/bin/ls ${desktopExpr "*"} | ${pkgs.findutils}/bin/xargs -L 1 ${pkgs.desktop-file-utils}/bin/desktop-file-edit --set-key=NoDisplay --set-value=true
# Show whitelisted
${pkgs.coreutils}/bin/ls ${builtins.concatStringsSep " " (builtins.map desktopExpr whitelist)} | ${pkgs.findutils}/bin/xargs -L 1 ${pkgs.desktop-file-utils}/bin/desktop-file-edit --remove-key=NoDisplay
echo "Done!"
'';
    in {
      Unit = {
        Description = "A service that hides non whitelisted waydroid desktop entries";
      };
      Service = {
        Type = "exec";
        ExecStart = "${fileHiderScript}/bin/hide-waydroid-files.sh";
      };
    };
  }; 
}
