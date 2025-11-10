{config, lib, pkgs, ...}: {
  imports = [
    ./users/pedro.nix
  ];
  security.rtkit.enable = true;
  musnix = {
    enable = true;
    soundcardPciId = "07:00.6";
    rtirq.enable = true;
    rtcqs.enable = true;
    das_watchdog.enable = true;
  };
}
