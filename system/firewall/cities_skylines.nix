{config, lib, pkgs, ...}: {
  networking.firewall = {
    allowedUDPPorts = [
      # Cities skylines
      4230
    ];
  };
}