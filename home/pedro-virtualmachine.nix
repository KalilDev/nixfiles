{config, lib, pkgs, ...}: {
  home.username = "pedro";
  home.homeDirectory = "/home/pedro";
  imports = [
    ./_standard.nix
  ];
}