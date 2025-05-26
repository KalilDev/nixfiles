{config, lib, pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Firefox pwa
    firefoxpwa
  ];
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [ firefoxpwa ];
  };

}