{config, pkgs, lib, ...}: {
  home.packages = [pkgs.wlr-hdr-cal];
  xdg.configFile."wlr-hdr-cal/config".text = ''
[[monitors]]
name = "DP-5"
multiplier = 1.0
values = [
  [0, 0],
  [100, 70],
  [175, 130],
  [200, 165],
  [400, 400],
  [10000, 10000]
]

'';
}
