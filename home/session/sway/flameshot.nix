{config, lib, pkgs, ...}: {

  options.flameshot.home.packages = lib.mkOption {
    type = with lib.types; listOf package;
    default = [];
    description = "Extra packages for flameshot config";
  };
  config = {
    flameshot.home.packages = with pkgs; [
        grim
    ];
    services.flameshot = {
        enable = true;
        package = pkgs.flameshot.override { enableWlrSupport = true; };
    };
  };
}