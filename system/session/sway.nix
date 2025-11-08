{config, lib, pkgs, ...}: {
  # Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  security.polkit.enable = true;
  security.rtkit.enable = true;
  programs.dconf.enable = true;
  fonts.fontconfig.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  xdg.portal = {
    enable = true;
    config.common.default = ["wlr"];
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
    ];
  };
  environment.systemPackages = (with pkgs; [
    grim
    slurp
    wl-clipboard
    mako
    alacritty
    rofi
  ]);

  services.gnome.gnome-keyring.enable = true;
  systemd.user.services.sway-polkit-gnome-authentication-agent = {
    description = "polkit-gnome-authentication-agent for sway session";
    wantedBy = ["sway-session.target"];
    wants = ["sway-session.target"];
    after = ["sway-session.target"];
    serviceConfig = {
    Type = "simple";
    ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    Restart = "on-failure";
    RestartSec = 1;
    TimeoutStopSec = 10;
    };
  };
}
