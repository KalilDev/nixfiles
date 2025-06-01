{config, lib, pkgs, ...}: {
  imports = [
    ./sway/waybar.nix
  ];
  custom.hyprland-session = let
  darkBg = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/KalilDev/dotfiles/refs/heads/master/.config/wallpaper/dark.png";
      sha256 = "0a43c0c023a0fd7f213f1ccc3caf0fae1a7c29ee538d75a95e722b59cdf4c843";
  };
  lightBg = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/KalilDev/dotfiles/refs/heads/master/.config/wallpaper/light.png";
      sha256 = "fcf32cd741148c3874ca514fe04b28038888acdb703fbf68cf5478fe2fae83dd";
  };
  in {
    enable = true;
    bar.command = "waybar";
    background = darkBg;
  };
}