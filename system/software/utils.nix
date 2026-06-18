{config, lib, pkgs, ...}: {
  services.gvfs = {
    package = pkgs.gnome.gvfs;
    enable = true;
  };
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
