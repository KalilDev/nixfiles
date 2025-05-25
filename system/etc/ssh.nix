{config, lib, pkgs, ...}: {
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  networking.firewall = {
    allowedTCPPorts = [
      # Openssh
      22
    ];
  };
}