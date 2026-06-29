{config, lib, pkgs, nixpkgs, ...}: {
  security.polkit.enable = true;
  security.rtkit.enable = true;
  programs.dconf.enable = true;
  # Fontconfig depends on qt5 and qtwebengine5...
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];
  fonts.fontconfig.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  security.pam.services.swaylock = {};
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true; # If you use GDM
  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];
  services.displayManager.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.debug = true;
  services.displayManager.defaultSession = "sway";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "pedro";
  services.displayManager.sessionPackages = [pkgs.sway];
  programs.sway.enable = true;
  programs.sway.package = null;
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
