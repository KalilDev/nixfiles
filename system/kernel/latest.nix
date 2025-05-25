{config, lib, pkgs, ...}: {
  boot.kernelParams = [  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
}