{config, lib, pkgs, nixpkgs-unstable, ...}: {
  environment.systemPackages = [
    # Firefox pwa
    nixpkgs-unstable.firefoxpwa
  ];
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = [ nixpkgs-unstable.firefoxpwa ];
  };

}