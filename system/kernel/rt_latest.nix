{config, lib, pkgs, ...}: {
  specialisation = {
    realtime = {
      inheritParentConfig = true;
      configuration = {
        boot.kernelParams = [  ];
        boot.kernelPackages = pkgs.linuxPackages-rt_latest;
      };
    };
    non_realtime = {
      inheritParentConfig = true;
      configuration = {
        boot.kernelParams = [  ];
        boot.kernelPackages = pkgs.linuxPackages_latest;
      };
    };
  };
}
