{config, lib, pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    firefoxpwa
    # TEMPORARY: Firefoxpwa broke spotify. use the client
    spotify
  ];
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [ firefoxpwa ];
  };
  networking.firewall.allowedTCPPorts = [ 57621 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];
  

}
