{ config, lib, pkgs, ...}: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pedro = {
    isNormalUser = true;
    extraGroups = [ "adbusers" "docker" "wheel" "network" "steam" "input" "video" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };
}