{config, lib, pkgs, ...}: {
  # Enable CUPS to print documents.
  environment.systemPackages = [pkgs.pciutils pkgs.mesa-demos];
}
