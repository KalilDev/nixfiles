{config, lib, pkgs, ...}: {
  xdg.configFile = let
    irsFiles = lib.mapAttrs'
      (name: type: {
        name = "easyeffects/irs/${name}";
        value.source = ./easyeffects/irs/${name};
      })
      (builtins.readDir ./easyeffects/irs);
    inputFiles = lib.mapAttrs'
      (name: type: {
        name = "easyeffects/input/${name}";
        value.source = ./easyeffects/input/${name};
      })
      (builtins.readDir ./easyeffects/input);
    outputFiles = lib.mapAttrs'
      (name: type: {
        name = "easyeffects/output/${name}";
        value.source = ./easyeffects/output/${name};
      })
      (builtins.readDir ./easyeffects/output);
  in
    irsFiles // inputFiles // outputFiles;
  services.easyeffects.enable = true;
}