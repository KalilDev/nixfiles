{config, lib, pkgs, ...}: {
  hardware.graphics = {
    extraPackages = [pkgs.mangohud];
    extraPackages32 = [pkgs.mangohud];
  };
  programs.gamescope = {
    enable = true;
    # TODO: Enable once it works on steam
    capSysNice = false;
    package = pkgs.gamescope;
  };
  environment.systemPackages = [ pkgs.steam-run ];
}
