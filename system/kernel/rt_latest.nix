{config, lib, pkgs, ...}: {
  specialisation = {
    realtime = {
      inheritParentConfig = true;
      configuration = {
        boot.kernelPatches = [ {
          name = "rt-config";
          patch = null;
          structuredExtraConfig = with lib.kernel; {
            PREEMPT_RT = yes;
            DRM_I915_GVT_KVMGT = lib.mkForce lib.kernel.unset; 
            DRM_I915_GVT = lib.mkForce lib.kernel.unset; 
          };
        }
        ];
      };
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
