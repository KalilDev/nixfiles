{config, lib, pkgs, ...}: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    file
    unzip
    zip
    unrar
    rar
    vim
    wget
  ]);
}