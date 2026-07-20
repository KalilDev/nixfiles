{config, lib, pkgs, ...}: {
  environment.systemPackages = [pkgs.nixos-firewall-tool];
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
  };
  networking.nftables.enable = true;
}
