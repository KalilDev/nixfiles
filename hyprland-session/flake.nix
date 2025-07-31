{
  description = "Hyprland session flake";

  inputs = {
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.49.0";
    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.49.0";
      inputs.hyprland.follows = "hyprland";
    };
    # home-manager must be followed
    # nixpkgs must be followed
  };

  outputs = inputs@{ hyprland, hy3, ... }: {
    homeManagerModules.shared = { config, lib, pkgs, ...}: {
      imports = [
        ./home/hyprland.nix
      ];
      config = {};
      options.custom.hyprland-session = let
        mkListOr = type: lib.types.oneOf [
          type
          (lib.types.listOf type)
        ];
        system = pkgs.stdenv.hostPlatform.system;
      in {
        mod = lib.mkOption {
          type = lib.types.str;
          default = "SUPER";
        };
        mod_shift = lib.mkOption {
          type = lib.types.str;
          default = "SUPER_SHIFT";
        };
        left = lib.mkOption {
          type = mkListOr lib.types.str;
          default = ["left" "h"];
        };
        down = lib.mkOption {
          type = mkListOr lib.types.str;
          default = ["down" "j"];
        };
        up = lib.mkOption {
          type = mkListOr lib.types.str;
          default = ["up" "k"];
        };
        right = lib.mkOption {
          type = mkListOr lib.types.str;
          default = ["right" "l"];
        };
        terminal = lib.mkOption {
          type = lib.types.str;
          default = "alacritty";
        };
        bar.command = lib.mkOption {
          type = lib.types.str;
          default = "waybar";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = hyprland.packages.${system}.hyprland;
        };
        portalPackage = lib.mkOption {
          type = lib.types.package;
          default = hyprland.packages.${system}.xdg-desktop-portal-hyprland;
        };
        plugins = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [
            hy3.packages.${system}.hy3
          ];
        };
        background = lib.mkOption {
          type = lib.types.str;
        };
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether or not to enable the customized hyprland session or not";
        };
      };
    };
    nixosModules.shared = { config, lib, pkgs, ...}:
      let 
        system = pkgs.stdenv.hostPlatform.system;
      in {
      imports = [
        ./system/hyprland.nix
      ];
      options.custom.hyprland-session = {
        package = lib.mkOption {
          type = lib.types.package;
          default = hyprland.packages.${system}.hyprland;
        };
        portalPackage = lib.mkOption {
          type = lib.types.package;
          default = hyprland.packages.${system}.xdg-desktop-portal-hyprland;
        };
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether or not to enable the customized hyprland session or not";
        };
      };
    };
  };
}
