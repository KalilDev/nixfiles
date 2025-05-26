{config, lib, pkgs, ...}: {
  boot.initrd.systemd.enable = true;
}