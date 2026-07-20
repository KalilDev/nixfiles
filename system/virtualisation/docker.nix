{config, lib, pkgs, ...}: {
  networking.firewall = {
    trustedInterfaces = [ "docker0" ];
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

}
