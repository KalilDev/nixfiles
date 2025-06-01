{config, lib, pkgs, ...}:
  let 
    custom = config.custom;
    enable = custom.hyprland-session.enable;
    package = custom.hyprland-session.package;
    portalPackage = custom.hyprland-session.portalPackage;
  in {
  config = lib.mkIf enable {
    programs.hyprland = {
      enable = true;
      package = package;
      portalPackage = portalPackage;
      xwayland.enable = true;
    };
    systemd.user.services.hyprland-polkit-gnome-authentication-agent = {
      description = "polkit-gnome-authentication-agent for hyprland session";
      wantedBy = ["hyprland-session.target"];
      wants = ["hyprland-session.target"];
      after = ["hyprland-session.target"];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
      };
    };
  };
}
