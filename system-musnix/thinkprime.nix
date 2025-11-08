{config, lib, pkgs, ...}: {
  imports = [
    ./users/pedro.nix
  ];
  security.rtkit.enable = true;
  musnix = {
    enable = true;
    soundcardPciId = "07:00.6";
    kernel.realtime = true;
    kernel.packages = pkgs.linuxPackages_latest_rt;
    rtirq.enable = true;
    rtcqs.enable = true;
    das_watchdog.enable = true;
  };
}
