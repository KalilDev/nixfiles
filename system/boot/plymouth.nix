{config, lib, pkgs, ...}: {
  boot.plymouth.enable = true;
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" ];
}