{config, lib, pkgs, ...}: {
  # Sway
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
#    wrapperFeatures.gtk = true;
  };
#  security.polkit.enable = true;
#  security.rtkit.enable = true;
#  programs.dconf.enable = true;
#  fonts.fontconfig.enable = true;
#  programs.gnupg.agent = {
#    enable = true;
#    enableSSHSupport = true;
#  };
#  xdg.portal = {
#    enable = true;
#    config.common.default = ["wlr"];
#    extraPortals = [
#      pkgs.xdg-desktop-portal-wlr
#    ];
#  };
  environment.systemPackages = (with pkgs; [
#    grim
#    slurp
#    wl-clipboard
#    mako
#    alacritty
#    rofi
    kitty
  ]);

#  services.gnome.gnome-keyring.enable = true;
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
}
