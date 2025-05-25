{config, lib, pkgs, ...}: {
  options.alacritty.home.packages = lib.mkOption {
    type = with lib.types; listOf package;
    default = [];
    description = "Extra packages for alacritty config";
  };
  config = {
    alacritty.home.packages = with pkgs; [
      alacritty
    ];
    programs.alacritty = {
      enable = true;
      settings = {
        colors.primary = {
          background = "0x1f1820";
          foreground = "0xf6ebf7";
        };
        cursor = {
          style = "Block";
          thickness = 0.15;
          unfocused_hollow = true;
        };
        mouse.bindings = [
          {
            action = "Paste";
            mouse = "Middle";
          }
          {
            action = "Copy";
            mouse = "Right";
          }
        ];
        window.opacity = 0.9;
        window.padding = { x = 16; y = 16; };
      };
    };
  };
}