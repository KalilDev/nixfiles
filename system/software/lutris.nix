{config, lib, pkgs, ...}: {
  environment.systemPackages = (with pkgs; [
    (lutris.override {
       extraPkgs = pkgs: [
         mangohud
         gamescope
       ];
    })
  ]);
}