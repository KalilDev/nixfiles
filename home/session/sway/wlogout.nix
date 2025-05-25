{config, lib, pkgs, ...}: {
  options.wlogout.home.packages = lib.mkOption {
    type = with lib.types; listOf package;
    default = [];
    description = "Extra packages for wlogout config";
  };
  config = {
    wlogout.home.packages = with pkgs; [
        wlogout
    ];
  };
}