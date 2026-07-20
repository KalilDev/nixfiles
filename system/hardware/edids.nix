{config, lib, pkgs, ...}: {
  imports = [ ./edid_patch.nix ];
  services.runtime-override-edid."6d1e:7766" = {
    edid = "./edids/lg_ultragear_dp.bin";
    connector = "DP";
  };
  #hardware.display.edid = let
  #patched_edids = pkgs.stdenv.mkDerivation {
  #  pname = "patched-edids";
  #  version = "1.0.0";
  #  src = ./edids;
  #  dontBuild = true;
  #  installPhase = ''
  #    mkdir -p $out/lib/firmware/edid
  #    cp -r ./* $out/lib/firmware/edid/
  #  '';
  #
  #  meta = {
  #    description = "Edids patched by me";
  #  };
  #};
  #in {
  #  enable = true;
  #  packages = [ patched_edids ];
  #};
  #hardware.display.outputs."DP-5".edid = "lg_ultragear_dp.bin";
  # I want to target the edid over display port only! Let hdmi be. So i need to set it manually on the kernel params
  # boot.kernelParams = [ "drm.edid_firmware=edid/GSM-7766:edid/lg_ultragear_dp.bin" ];
  #boot.initrd.extraFiles."/lib/firmware/edid".source = lib.mkIf config.hardware.display.edid.enable 
  #  "${config.hardware.display.edid.packages}/lib/firmware/edid";
  
}
