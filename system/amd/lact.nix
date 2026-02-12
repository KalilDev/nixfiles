{config, lib, pkgs, ...}: {
  environment.systemPackages = [pkgs.lact];
  systemd.packages = [pkgs.lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
  systemd.services.lactd.enable = true;
}
