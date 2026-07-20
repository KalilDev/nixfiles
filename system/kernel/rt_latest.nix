{config, lib, pkgs, ...}: {
  specialisation = {
    realtime = {
      inheritParentConfig = true;
      configuration = {
       system.requiredKernelConfig = [
         (config.lib.kernelConfig.isEnabled "PREEMPT_RT")
        ];
      };
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
