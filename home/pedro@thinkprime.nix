{config, lib, pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  home.username = "pedro";
  home.homeDirectory = "/home/pedro";
  import = [
    ./_standard.nix
  ]
}