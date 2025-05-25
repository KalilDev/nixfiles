{ config, pkgs, lib, ... }:
let 
  luksDevice = "/dev/disk/by-uuid/489265c5-852c-4327-84b8-a2b6f448f98c";
  luksName = "cryptroot";
  keyFilePath = "/dev/disk/by-id/usb-SanDisk_Ultra_4C531001490317105334-0:0";
  keyFileOffset = 15376280064;
  keyFileSize = 4096;
  vgName = "cryptroot";
  lvName = "root";
  btrfsDevice = "/dev/${vgName}/${lvName}";
  btrfsHomeSubvol = "@home";
  btrfsRootSubvol = "@";
  mountpoint = "/media/external_ssd";
  mountpointUnitized = "${lib.strings.replaceStrings ["/"] ["-"] (lib.removePrefix "/" mountpoint) }";
  mountpointUnit = "${mountpointUnitized}.mount";
  automountTimeout = 15;
  automountIdleTimeout = 300;
in {

  environment.systemPackages = with pkgs; [ cryptsetup lvm2 lvm2.bin util-linux ];

  systemd.services."cryptsetup-${luksName}" = {
    description = "Lazily unlock ${mountpoint} LUKS volume";
    before = [ mountpointUnit ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''
        ${pkgs.cryptsetup}/bin/cryptsetup open \
          --type luks \
          --key-file ${keyFilePath} \
          --keyfile-offset ${toString keyFileOffset} \
          --keyfile-size ${toString keyFileSize} \
          ${luksDevice} ${luksName}
      '';
      ExecStop = ''
        ${pkgs.cryptsetup}/bin/cryptsetup close ${luksName}
      '';
    };
  };

  systemd.services."vg-activate-${vgName}" = {
    description = "Lazily activate LVM VG for ${mountpoint}";
    requires = [ "cryptsetup-${luksName}.service" ];
    partOf = [ "${mountpointUnitized}-home.mount" ];
    bindsTo = [ "dev-mapper-${luksName}.device" ];
    after = [ "dev-mapper-${luksName}.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "udevadm settle";
      ExecStart = "${pkgs.lvm2.bin}/bin/vgchange -ay ${vgName}";
      ExecStop = "${pkgs.lvm2.bin}/bin/vgchange -an ${vgName}";
    };
  };

#  fileSystems."${mountpoint}" = {
#    device = btrfsDevice;
#    fsType = "btrfs";
#    options = [
#      "subvol=${btrfsRootSubvol}"
#      "x-systemd.automount"
#      "noauto"
#      "x-systemd.requires=vg-activate-${vgName}.service"
#      "x-systemd.before=${mountpointUnit}"
#      "x-systemd.device-timeout=${toString automountTimeout}"
#      "x-systemd.idle-timeout=${toString automountIdleTimeout}"
#    ];
#  };

  fileSystems."${mountpoint}/home" = {
    device = btrfsDevice;
    fsType = "btrfs";
    options = [
      "subvol=${btrfsHomeSubvol}"
      "x-systemd.automount"
      "noauto"
      "x-systemd.before=${mountpointUnitized}-home.mount"
      "x-systemd.device-timeout=${toString automountTimeout}"
      "x-systemd.idle-timeout=${toString automountIdleTimeout}"
    ];
  };

  systemd.services."${mountpointUnitized}-lazy-cleanup" = {
    description = "Graceful lazy cleanup of ${mountpoint}";
    before = [ "shutdown.target" ];
    conflicts = [ "umount.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = ''
        ${pkgs.util-linux}/bin/umount -l ${mountpoint}/home || true
        #${pkgs.util-linux}/bin/umount -l ${mountpoint} || true
        ${pkgs.lvm2.bin}/bin/vgchange -an ${vgName} || true
        ${pkgs.cryptsetup}/bin/cryptsetup close ${luksName} || true
      '';
      TimeoutStopSec = 60;
    };
    wantedBy = [ "shutdown.target" ];
  };
}
