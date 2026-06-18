{config, lib, pkgs, ...}: {
  specialisation = {
    realtime = {
      inheritParentConfig = true;
      configuration = {
        boot.kernelParams = [  ];
        boot.kernelPackages = pkgs.linuxPackages-rt_latest;
      };
    };
  };
  boot.kernelParams = lib.mkIf (config.specialisation != {}) [  ];
  boot.kernelPackages = lib.mkIf (config.specialisation != {}) pkgs.linuxPackages_latest;
}
