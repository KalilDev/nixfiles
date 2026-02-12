{config, lib, pkgs, ...}: {
  networking.firewall = {
    allowedTCPPortRanges = [
      { from = 1800; to = 1900; }
    ];
    allowedUDPPortRanges = [
      { from = 1800; to = 1900; }
    ];
  };
}
