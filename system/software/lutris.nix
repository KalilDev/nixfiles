{config, lib, pkgs, ...}: {
  environment.systemPackages = (with pkgs; [
    (lutris.override {
       extraPkgs = pkgs: [
         mangohud
         pkgs.pin-9e1f33.gamescope
       ];
    })
  ]);
}
