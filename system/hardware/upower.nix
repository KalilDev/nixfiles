{config, lib, pkgs, ...}: {

  services.upower = {
    enable = true;
  };
  services.power-profiles-daemon.enable = true;
}