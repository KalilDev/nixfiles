{config, lib, pkgs, ...}: {
  boot.kernelModules = [ "amdgpu" ];

  hardware = {
    amdgpu.opencl.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
        rocmPackages.clr.icd
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
        driversi686Linux.amdvlk
      ];
    };
  };
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };

  environment.systemPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
  
  nixpkgs.config.rocmSupport = true;
}
