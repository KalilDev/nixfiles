{config, pkgs, lib, ...}: {
  home.packages = [pkgs.wlr-hdr-cal];
  xdg.configFile."wlr-hdr-cal/config".text = ''
[[monitors]]
name = "GSM 30566"
values = [
  [0, 0],
  [100, 60],
  [200, 140],
  [10000, 10000]
]
'';
}
