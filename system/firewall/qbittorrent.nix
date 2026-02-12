{config, lib, pkgs, ...}: {
  networking.firewall = {
    allowedTCPPorts = [
      # qBittorrent
      9050
    ];
  };
}
