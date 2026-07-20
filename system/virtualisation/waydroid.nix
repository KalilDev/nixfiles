{config, lib, pkgs, ...}: {
  virtualisation.waydroid.enable = true;
  environment.systemPackages = [pkgs.wl-clipboard pkgs.waydroid-helper];
systemd = {
  packages = [ pkgs.waydroid-helper ];
  services.waydroid-mount.wantedBy = [ "multi-user.target" ];
};

}
