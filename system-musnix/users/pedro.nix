{ config, lib, pkgs, ...}: {
  users.users.pedro.extraGroups = [ "audio" ];
}
